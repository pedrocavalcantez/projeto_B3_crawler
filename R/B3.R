#' @title DEPARA SETOR NOME EMPRESA
#' @name ticker_empresa
#'
#' @description A partir de um crawler oriundo do site da b3, cria um depara entre a empresa e setor atuante
#'
#' @return dataframe com nome da empresa e seus setores
#' @import dplyr
#' @author Pedro Cavalcante
#' @examples
#' buscar_setores()

#' @export

buscar_setores <- function() {
  temp <- "a.xlsx"
  download.file(
    "http://www.b3.com.br/lumis/portal/file/fileDownload.jsp?fileId=8AA8D0975A2D7918015A3C81693D4CA4",
    temp,
    mode = "wb"
  )
  nome_arquivo = as.character(unzip(temp, list = TRUE)[1])
  unzip(temp, files = nome_arquivo)
  df = xlsx::read.xlsx(nome_arquivo, sheetIndex = 1, encoding = "UTF-8")
  df = df[rowSums(!is.na(df)) != 0, ]
  colnames(df) = c(
    "str_setor",
    "str_subsetor",
    "str_nome_cia_setor",
    "str_codigo",
    "str_mercado",
    "str_segmento"
  )
  df = df %>% filter(str_mercado != "SEGMENTO" |
                       is.na(str_mercado)) %>%
    mutate(str_segmento = ifelse(
      is.na(str_codigo) & is.na(str_segmento),
      str_nome_cia_setor,
      NA
    ))
  df[, c("str_setor", "str_subsetor", "str_segmento")] = zoo::na.locf(df[, c("str_setor", "str_subsetor", "str_segmento")], na.rm =
                                                                        FALSE)
  df = df %>% filter(!is.na(str_codigo) |
                       str_nome_cia_setor != "SEGMENTO") %>% mutate(str_nome_cia_setor = trimws(str_nome_cia_setor))
  unlink(temp)
  unlink(nome_arquivo)
  df = df %>% dplyr::filter(str_codigo != "LISTAGEM")
  
  return(df)
}