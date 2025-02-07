# Carregar pacotes necessários
pacman::p_load(tidyverse, janitor, rio, sidrar, glue)

# ------------ Seleção de Municípios ------------
municipios_import <- rio::import('lista_municipios.xlsx', sheet = 'Planilha1', setclass = 'tibble') |> 
  clean_names()

municipios <- str_c('n6/', paste0(municipios_import$codigo_municipio_completo, collapse = ","))

# ------------ Definição de Parâmetros para API SIDRA ------------
piaui <- 'n3/22'      # Código do Estado do Piauí no SIDRA
periodo <- "p/2017"   # Ano de referência (Censo Agropecuário)
eaf <- 'c829/46304'   # Estabelecimentos Agropecuários de Agricultura Familiar
raca <- 'c830/all'    # Desagregação por cor/raça
sexo <- 'c12564/all'  # Desagregação por sexo

# ------------ Extração de Dados ------------

# Estabelecimentos Agropecuários por Sexo e Raça (Censo Agro 2017)
eaf_sexo_raca <- get_sidra(api = glue('/t/6776/{periodo}/v/9998/{eaf}/{sexo}/c800/41147/{raca}/{piaui}')) |> 
  clean_names() |> 
  group_by(tipologia, sexo_do_produtor, cor_ou_raca_do_produtor) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export('outputs/6776_eaf_sexo_raca.xlsx')

# População Total (Censo 2010)
populacao_2010 <- get_sidra(api = glue('/t/3175/p/last/v/93/c86/0/c1/all/c2/all/c287/0/{piaui}')) |> 
  clean_names() |> 
  group_by(sexo, situacao_do_domicilio) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export("outputs/3175_pop_total_2010.xlsx")

# População por Faixa Etária (Censo 2010)
populacao_2010_idade <- get_sidra(api = glue('/t/3175/p/last/v/93/c86/0/c1/all/c2/all/c287/93070,93084,93085,93086/{piaui}')) |> 
  clean_names() |> 
  mutate(idade = case_when(
    idade %in% c('0 a 4 anos', '5 a 9 anos', '10 a 14 anos') ~ 'Crianças (até 15 anos)',
    idade %in% c('15 a 19 anos', '20 a 24 anos', '25 a 29 anos') ~ 'Jovens (15 a 29 anos)',
    idade %in% c('30 a 64 anos') ~ 'Adultos (30 a 64 anos)',
    idade %in% c('65 anos ou mais') ~ 'Idosos (acima de 65 anos)'
  )) |> 
  group_by(sexo, idade, situacao_do_domicilio) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export("outputs/3175_pop_idade_2010.xlsx")

# População por Sexo e Idade (Censo 2022)
populacao_2022 <- get_sidra(api = glue('/t/9514/p/last/v/93/c2/all/c287/100362/{piaui}')) |> 
  clean_names() |> 
  group_by(sexo, idade) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export("outputs/9514_pop_total_2022.xlsx")

# População Quilombola (Censo 2022)
quilombola_pessoas <- get_sidra(api = glue('/t/9578/p/2022/v/4709/c2661/all/{municipios}')) |> 
  clean_names() |> 
  group_by(localizacao_do_domicilio) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export("outputs/quilombolas_2022.xlsx")

# População Indígena (Censo 2022)
populacao_2022_indigenas <- get_sidra(api = glue('/t/9608/p/all/v/350/c58/all/c2/all/{municipios}')) |> 
  clean_names() |> 
  mutate(grupo_de_idade = case_when(
    grupo_de_idade %in% c('0 a 14 anos') ~ 'Crianças',
    grupo_de_idade %in% c('15 a 29 anos') ~ 'Jovens',
    grupo_de_idade %in% c('30 a 64 anos') ~ 'Adultos',
    grupo_de_idade %in% c('65 anos ou mais') ~ 'Idosos'
  )) |> 
  group_by(ano, sexo, grupo_de_idade) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export("outputs/9608_pop_indigenas_2022.xlsx")

# Analfabetismo por Raça e Sexo (Censo Agro 2017)
analfabetismo <- get_sidra(api = glue('/t/6755/{periodo}/v/9998/{eaf}/{sexo}/c800/46510/{raca}/{piaui}')) |> 
  clean_names() |> 
  mutate(classe_de_idade_do_produtor = case_when(
    classe_de_idade_do_produtor %in% c('Menor de 25 anos', 'De 25 a menos de 35 anos') ~ 'Menos de 35 anos',
    classe_de_idade_do_produtor %in% c('De 35 a menos de 55 anos') ~ 'De 35 a 55 anos',
    classe_de_idade_do_produtor %in% c('De 55 a menos de 75 anos') ~ 'De 55 a 75 anos',
    classe_de_idade_do_produtor %in% c('De 75 anos e mais') ~ 'Acima de 75 anos'
  )) |> 
  group_by(cor_ou_raca_do_produtor, sexo_do_produtor, escolaridade_do_produtor, classe_de_idade_do_produtor) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export('outputs/6755_analfabetismo.xlsx')

# Acesso a Recursos Hídricos por Sexo (Censo Agro 2017)
acesso_rec_hid <- get_sidra(api = glue('/t/6860/{periodo}/v/2324/{eaf}/{sexo}/c218/46502/{piaui}')) |> 
  clean_names() |> 
  group_by(tipo_de_recurso_hidrico, sexo_do_produtor) |> 
  summarise(total = sum(valor, na.rm = TRUE)) |> 
  rio::export("outputs/6860_rec_hidri.xlsx")

# ----------------- FIM -----------------
