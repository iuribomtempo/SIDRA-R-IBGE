# SIDRA-R-IBGE
Extração de microdados dados 
# Extracao de Dados do IBGE via SIDRA

## Descricao
Este repositório contém um script em **R** para extrair, processar e exportar dados do **IBGE (Instituto Brasileiro de Geografia e Estatística)** via API **SIDRA**. O foco da coleta de dados está em informações demográficas e agrícolas relacionadas ao **Censo Agropecuário e Censo Demográfico**.

## Funcionalidades
- **Extração de dados via API SIDRA** com consultas parametrizadas.
- **Processamento e limpeza de dados** usando `tidyverse` e `janitor`.
- **Exportação dos dados** em arquivos Excel (`.xlsx`).
- **Agrupamento e sumarização** de informações por sexo, cor/raça, idade e situação domiciliar.

## Tecnologias Utilizadas
- **R**
- **Pacotes:** `tidyverse`, `janitor`, `rio`, `sidrar`, `glue`, `pacman`

## Estrutura do Projeto
```
/
|-- inputs/               # Arquivos de entrada (ex: lista de municípios, Cadastro Único, SISVAN)
|-- outputs/              # Arquivos de saída (.xlsx) com os dados processados
|-- script.R              # Script principal de extração e processamento de dados
|-- README.md             # Documentação do projeto
```

## Como Usar
### 1. Instale os pacotes necessários
Caso ainda não tenha os pacotes instalados, execute:
```r
install.packages(c("tidyverse", "janitor", "rio", "sidrar", "glue", "pacman"))
```

### 2. Execute o Script
Abra o **RStudio** ou terminal e execute:
```r
source("script.R")
ou faça célula a célula para a extração individualizada
```
Isso processará os dados e gerá arquivos na pasta `outputs/`.

## Consultas Disponíveis
O script realiza extração para diferentes conjuntos de dados, incluindo:
- **Censo Agropecuário (2017)**: Estabelecimentos agropecuários por tipologia, sexo, cor/raça.
- **Censo Demográfico (2010 e 2022)**: População por idade, sexo, cor/raça e situação domiciliar.
- **População Indígena e Quilombola**: Distribuição geográfica e condição domiciliar.
- **Acesso a Recursos Hídricos e Irrigação**.
- **Produção Agropecuária e Acesso a Assistência Técnica**.

## Exemplo de Consulta
Consulta ao SIDRA para obter dados do **Censo Agropecuário 2017**:
```r
eaf_sexo_raca <- get_sidra(api = glue('/t/6776/p/2017/v/9998/c829/46304/c12564/all/c800/41147/c830/all/n3/22')) |>
  tibble() |>
  clean_names() |>
  group_by(tipologia, sexo_do_produtor, cor_ou_raca_do_produtor) |>
  summarise(total = sum(valor, na.rm = TRUE)) |>
  rio::export('outputs/6776_af_naf_sexo_raca.xlsx')
```

## Contato
Caso tenha dúvidas ou sugestões, fique à vontade para abrir uma **issue** ou entrar em contato via GitHub.

---
**Autor: Iuri Bomtempo

