tabPanel('Input',
         sidebarLayout(
           sidebarPanel(
             inline(actionButton("showFileInput", "Tutorial", icon = icon("info") )),
             inline(
               downloadButton(
                 "downloadManual",
                 "User manual"
                 )
               ),
             br(),
             conditionalPanel(
               condition = "output.uploadSuccess",
               HTML(
                 '<h3 style="color: #339999;"> Successfully uploaded data.<br>
                 Refresh this page to upload another data set.</h3>
                 <h4>Use the tabs on top of the page to see the generated interactive plots (QC, Diff abundance).</h4>
                 <h4>Summary of imported data shown on the right.</h4>
                  <p></p>'
               )
            ),
             conditionalPanel(
               condition = "!output.uploadSuccess",
             h4("File input"),
             radioButtons(
               inputId = "source",
               label = "Select the file input.",
               choices = c(
                 "Upload amica format" = "amica",
                 "Upload LFQ" = "maxquant",
                 "Upload DIA" = "dia",
                 "Upload TMT" = "tmtFP",
                 "Upload custom format" = "custom",
                 "Load in example" = "example"
               )
             ),
             helpText(
               "If 'amica' is selected previous output gets loaded in. When 'LFQ' is selected,
               MaxQuant or FragPipe output can be processed. 'DIA' allows for the upload
               of DIA-NN and Spectronaut output. Finally, if 'custom' is selected any tabular format
               can be uploaded, provived a 'specification' file is uploaded.
               Differential abundance get's computed with limma or DEqMS, 
                     for this you have to upload an additional 'contrast matrix' to your experimental 'design'."
             ),
             br(),
             
             conditionalPanel(
               # The condition should be that the user selects
               # "file" from the radio buttons
               condition = "input.source == 'amica'",
               inline(h4("1) protein groups table (amica format)")),
               inline(actionButton("showAmicaInput", "", icon = icon("info") )),
               fileInput("amicaFile", "e.g. amica_protein_table.tsv", width = "60%"),
               helpText(
                 "Have you run amica before? Input the amica output from a previous session."
               )
             ),
             conditionalPanel(
               # The condition should be that the user selects
               # "file" from the radio buttons
               condition = "input.source == 'maxquant'",
               h4("1) MaxQuant or FragPipe input"),
               fileInput(
                 "maxquantFile",
                 "Upload 'proteinGroups.txt' file from MaxQuant or 'combined_protein.tsv' from FragPipe.",
                 width = "60%"
               )
             ),
             conditionalPanel(
               # The condition should be that the user selects
               # "file" from the radio buttons
               condition = "input.source == 'dia'",
               h4("1) DIA-NN or Spectronaut input"),
               fileInput(
                 "diaFile",
                 "Upload PG matrix from DIA-NN or PG report from Spectronaut.",
                 width = "60%"
               )
             ),
             conditionalPanel(
               # The condition should be that the user selects
               # "file" from the radio buttons
               condition = "input.source == 'tmtFP'",
               h4("1) FragPipe's TMT"),
               fileInput(
                 "tmtFPFile",
                 "Upload '[abundance/ratio]_protein_[normalization].tsv' file from FragPipe.",
                 multiple = F,
                 width = "60%"
               )
             ),
             conditionalPanel(
               # The condition should be that the user selects
               # "file" from the radio buttons
               condition = "input.source == 'custom'",
               h4("1) Custom input"),
               fileInput("customFile", "Upload custom tab delimited file.", width = "60%"),
               helpText(
                 "File needs to be tab-delimited and it needs to contain a unique
                 ProteinId, Gene name and an intensity prefix."
               ),
               checkboxInput(
                 'customDataLogTransform',
                 'Log2 transform intensities of custom data?',
                 value = TRUE
               )
             ),
             
             conditionalPanel(
               condition = "input.source != 'example'",
               inline(h4("2) Experimental design")),
               inline(actionButton("showDesign", "", icon = icon("info") )),
               
               fileInput(
                 "groupSpecification",
                 "e.g. amica_design.tsv",
                 c('.tsv', 'text/plain', 'text/tsv',
                  #'text/csv',
                   'text/comma-separated-values,text/plain'),
                 multiple = F,
                 width = "60%"
               ),
               helpText(
                 "A tab-separated file containing the sample name ordered in appearance in the uploaded file and its corresponding group."
               ),
             ),
             
             conditionalPanel(
               condition = "input.source != 'example' && input.source != 'amica'",
               inline(h4("3) Contrast matrix")),
               inline(actionButton("showContrasts", "", icon = icon("info") )),
               fileInput(
                 "contrastMatrix",
                 "Contrast matrix (group comparisons)",
                 c('text/csv',
                   'text/comma-separated-values,text/plain'),
                 multiple = F,
                 width = "60%"
               ),
               helpText(
                 "A tab-separated file with the sample-of-interest in the first column and the sample it is getting compared to in the second column."
               ),
             ),
             conditionalPanel(
               # The condition should be that the user selects
               # "file" from the radio buttons
               condition = "input.source == 'custom'",
               inline(h4("4) Specification file")),
               inline(actionButton("showSpecifications", "", icon = icon("info") )),
               fileInput("specFile", "Upload a specification file in tab delimited format.",
                         width = "60%"),
               helpText(
                 "File needs to have two columns: the column 'Variable' which defines the variable and 
                       'Pattern' which is the column name or a pattern."
               )
             )
             ),##############
            br(), br(), br(),
            conditionalPanel(
              condition = "input.source == 'example'",
              
              actionButton('exampleHelp', label = '', icon = icon("info")),
              uiOutput("exampleHelpBox"),
              br(),
              br()
            ),
            downloadButton("exampleFiles",
                           "Example input"),
            inline(actionButton("showReportingStandards", "Reporting standards", icon = icon("info") )),
            br(), br(), br(),
            
            ######## PARAMETERS BEGIN
            conditionalPanel(condition = "!output.analysisSuccess",
                             actionButton("submitAnalysis", "Upload")), 
             #actionButton("resetAnalysis", "Reset"),
             
             conditionalPanel(
               condition = "input.source != 'example' 
                     && input.source != 'amica' 
                     && input.submitAnalysis!=0
                     && output.uploadSuccess
                     && !output.amicaInput",
               h3("Analysis Parameters"),
               bsCollapse(
                 id = "collapseExample",
                 open = "Panel 2",
                 bsCollapsePanel(
                   "Advanced",
                   #style="info",
                   h4("Filter on count values"),
                   numericInput(
                     "minRazor",
                     "min. razor peptides",
                     min = 1,
                     value = 2
                   ),
                   helpText(
                     "Default is 2. It is difficult to distinguish
                     quantitative effects on the protein level from peptide
                     specific effects for 'one-hit wonders'."
                   ),
                   numericInput("minMSMS", "min. MSMS count", min = 1, value = 3),
                   
                   h4("Filter on valid values per group"),
                   uiOutput("filterValuesInput"),
                   radioButtons(
                     "validValuesGroup",
                     "Require min valid values in at least one group or in all groups?",
                     choices = c("in_one_group", "in_each_group"),
                     selected = "in_one_group"
                   ),
                   numericInput(
                     "minValidValue",
                     "Min. valid values in group",
                     min = 1,
                     value = 3
                   ),
                   
                   h4("Normalization and statistical testing"),
                   conditionalPanel(
                     condition = "input.source == 'maxquant'",
                     uiOutput("intensitySelection")
                   ),
                   radioButtons(
                     "renormalizationMethod",
                     "Normalization method",
                     choices = c("None", "Quantile", "VSN", "Median.centering"),
                     selected = "None"
                   ),
                   helpText("The renormalization utilzes LFQ intensities."),
                   checkboxInput(
                     "limmaTrend",
                     "use DEqMS? If not selected differential abundant proteins are detected by limma.",
                     value = FALSE
                   ),
                   helpText(
                     "DEqMS takes the number of PSMs of a protein into account for quantitation."
                   ),
                   
                   h4("Imputation"),
                   radioButtons(
                     "impMethod",
                     "Imputation method",
                     choices = c("normal", "min", "global", "None"),
                     selected = "normal"
                   ),
                   
                   
                   helpText(
                     "'normal' samples from the
                     normal distribution of all intensities
                     from the same sample but dowshifted.
                     Min takes the minimum observed value
                     which is useful for analyzing pilots"
                   ),
                   numericInput(
                     "downshift",
                     "Imputation downshift",
                     value = 1.8,
                     min = 0,
                     step = 0.01
                   ),
                   numericInput(
                     "width",
                     "Imputation width",
                     value = 0.3,
                     min = 0,
                     step = 0.01
                   ),
                   style = "info"
                 )
                 
               ),
               actionButton("runAnalysis", "Analyze"),
             )
             
             ######## PARAMETERS END
           )
           
           ,
           mainPanel(
             #h1("amica"),

            conditionalPanel(
               condition = "!output.uploadSuccess",
                 
                HTML('<center><img src="ga_amica.png" width="50%"></center>'),
                #img(src = 'ga_amica.svg',  align = "center"),
                br(),
                br(),
                br(),
                p(
                  "
                  amica is an interactive and user-friendly web-based platform that accepts proteomic 
                  input files from different sources and provides automatically 
                  generated quality control, set comparisons, differential expression,
                  biological network and over-representation analysis on the basis 
                  of minimal user input."
                ),
                p(
                  "Upload the required input files (explained on the sidebar) and the full functionality will be revealed."
                ),
                br(),
                br()
              ),

              conditionalPanel(
                condition ="output.uploadSuccess",

                uiOutput("uploadSuccessMsg"),
                br(), br(),
                uiOutput("download_amica"),
                br(), br(), br(),
                verbatimTextOutput("summaryText", placeholder = F),

                conditionalPanel(
                  condition = "!output.analysisSuccess",
                  uiOutput("analysisSuccessMsg")
                ),

                DTOutput("inputParamDT"),
                #verbatimTextOutput("inputParameterSummary", placeholder = F),
                shinyjs::hidden(div(
                  id = 'hide_before_input',
                  bsCollapse(
                    id = "colorCollapse",
                    open = "Panel beneath",
                    
                    bsCollapsePanel(
                      style = "info",
                      "Click to choose colors and ordering of groups in plots",
                      p(
                        "All visualizations are interactive and created with plotly.
                                                                When you hover over a plot with your mouse a toolbar is visable in the top right corner.
                                                                For some plots (volcano -, MA - and fold change plots) you can select data points with the select box or lasso functions which annotates the data points.
                                                                Plots can be downloaded in svg format when clicking on the camera icon."
                      ),
                      tabsetPanel(
                        type = "tabs",
                        tabPanel(h4("Available color palettes"),
                                  plotOutput("brewercols", height = "800px")),
                        tabPanel(h4("Qualitative (groups)"),
                                  HTML("
                                            <p>
                                            Each experimental group can be assigned 
                                            a color that stays consistent for various 
                                            QC plots (PCA, boxplots, barplots, etc.) 
                                            and heatmaps.
                                            </p>"),
                                  uiOutput("brewerOptionsQual"),
                                  radioButtons(
                                    "revQual",
                                    "Reverse colors?",
                                    choices = c("yes", "no"),
                                    selected = "no"
                                  ),
                                  uiOutput('myColorPanel')
                        ),
                        tabPanel(h4("Qualitative (scatter)"),
                                  HTML("
                                            <p>
                                            These colors will be used for scatter -,
                                            volcano -, MA - and fold change plots, 
                                            as well as for PPI networks.
                                            </p>"),
                                  selectInput(
                                    "brewerOptionsScatter",
                                    "Scatter plot colors",
                                    choices = c(
                                      "RdYlBu",
                                      "RdYlGn",
                                      "Spectral",
                                      "Accent",
                                      "Dark2",
                                      "Paired",
                                      "Pastel1",
                                      "Pastel2",
                                      "Set1",
                                      "Set2",
                                      "Set3"
                                    ),
                                    multiple = F,
                                    selected = "Paired"
                                  ),
                                  radioButtons(
                                    "revScatter",
                                    "Reverse colors?",
                                    choices = c("yes", "no"),
                                    selected = "no"
                                  ),
                                  plotlyOutput("irisScatter", height = 800),
                                  helpText("This famous (Fisher's or Anderson's) iris data set gives
                                                the measurements in centimeters of the variables sepal 
                                                length and width and petal length and width, respectively, 
                                                for 50 flowers from each of 3 species of iris. 
                                                The species are Iris setosa, versicolor, and virginica.")
                        ),
                        tabPanel(
                          h4("Diverging"),
                          uiOutput("brewerOptionsDiv"),
                          radioButtons(
                            "revDiv",
                            "Reverse colors?",
                            choices = c("yes", "no"),
                            selected = "yes"
                          ),
                          plotlyOutput("mtcarsHeatmap", height = 800),
                          helpText(
                            "The Motor Trend Car Road Tests was extracted from the 1974 Motor Trend US magazine, and comprises fuel consumption and 10 aspects of automobile design and performance for 32 automobiles (1973–74 models)."
                          )
                        ),
                        tabPanel(
                          h4("Order of groups in plots"),
                          uiOutput("groupFactors"),
                          helpText("If you only select a subset of groups 
                                          the unselected groups will not be plotted."),
                          inline(actionButton("submitGroupFactors", "Submit factors")),
                          inline(actionButton("resetGroupFactors", "Reset factors")),
                          verbatimTextOutput("groupFactorsSummary")
                        )
                      )
                    )
                  )
                )),
                br(), br(), br(),
                h3(textOutput("designTitle")),
                DTOutput("expDesignDT")
              ),

             
             footer()#p("This is footer"))
           )
         )
)