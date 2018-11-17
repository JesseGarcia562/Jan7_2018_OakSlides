#cd /u/home/j/jessegar/project-klohmuel/oakTrees/code
#module load R/3.5.0
#R
library(tidyverse)
library(glue)

bootstrapDirectory <- '/u/flashscratch/j/jessegar/Bootstraps'
directories <- list.dirs(bootstrapDirectory, recursive = F)
bootstrapDf <- tibble(
  directories = directories,
  species = str_extract(directories, 'q[lr]ob'),
  bootstrap = parse_number(str_extract(directories, '[0-9]+$')),
  files = list.files(
    path = directories,
    pattern = 'oak.msmc.out.final.txt',
    full.names = T
  )
)

bootstrapDf$files <-
  bootstrapDf$files %>% map( ~ read_delim(
    file = .x,
    delim = '\t',
    col_names = T
  ))
bootstrapDf <- bootstrapDf %>% unnest(files)



#####Q Lobata setup
qLobBootstrap <- bootstrapDf %>% filter(species == 'qlob')
qLobMu <- 2.5e-09
qLobGen <- 50
qLobBootstrap <- qLobBootstrap %>%
  mutate(
    Time = left_time_boundary / qLobMu * qLobGen,
    EffectivePopulationSize = (1 / lambda_00) / (2 * qLobMu)
  ) %>%
  mutate(data = 'Q. lobata bootstraps')

#####Q Robur setup
qRobBootstrap <- bootstrapDf %>% filter(species == 'qrob')
qRobMu <- 2.5e-09
qRobGen <- 30
qRobBootstrap <- qRobBootstrap %>%
  mutate(
    Time = left_time_boundary / qLobMu * qRobGen,
    EffectivePopulationSize = (1 / lambda_00) / (2 * qRobMu)
  ) %>%
  mutate(data = 'Q. robur bootstraps')



######Creating plot
bind_rows(qLobBootstrap, qRobBootstrap) %>%
  ggplot(aes(
    x = Time,
    y = EffectivePopulationSize,
    group = interaction(bootstrap, data),
    color = data
  )) +
  geom_step() +
  theme_bw(text = element_text(size=20)) +
  scale_x_continuous(trans = 'log10', labels = scales::comma) +
  scale_y_continuous(trans = 'log10') +
  labs(
    x = 'Years Ago',
    y = 'Effective Population Size',
    title = 'PSMC inference for Q. lobata and Q. robur',
    colour = 'Data Type',
    subtitle = glue(
      'Mutation rate = 2.5e-09/bp/gen
                     Q. lobata generation time = {qLobGen} years
                     Q. robur generation time = {qRobGen} years'
    )
  )

date<-format(Sys.Date(), "_%m_%d_%y")

ggsave(glue("../analysis/PSMCBootstrapsEmpirical_Qrob_Qlob_PSMC.pdf"), width=30, height=10)
ggsave(glue("../analysis/PSMCBootstrapsEmpirical_Qrob_Qlob_PSMC{date}.pdf"), width=30, height=10)
