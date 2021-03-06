#' Create an ECharts widget
#'
#' Create an HTML widget for ECharts that can be rendered in the R console, R
#' Markdown documents, or Shiny apps. You can add more components to this widget
#' and customize options later. \code{eChart()} is an alias of \code{echart()}.
#' @param data a data object (usually a data frame or a list)
#' @rdname eChart
#' @export
#' @examples library(rechartsX)
#' echart(iris, ~ Sepal.Length, ~ Sepal.Width)
#' echart(iris, ~ Sepal.Length, ~ Sepal.Width, series = ~ Species)
echart = function(data, ...) {
    UseMethod('echart')
}

#' Create an ECharts widget
#'
#' echart method for list
#' @param width width
#' @param height height
#' @export
#' @rdname eChart
echart.list = function(data, width = NULL, height = NULL,  ...) {
    htmlwidgets::createWidget(
        'echarts', x = data, width = width, height = height,
        package = 'rechartsX'
    )
}

#' Create an ECharts widget
#'
#' echart method for data.frame
#' @param x the x variable
#' @param y the y variable
#' @param series series
#' @param type type, default 'auto'
#' @export
#'
#' @rdname eChart
echart.data.frame = function(
    data = NULL, x = NULL, y = NULL, series = NULL, type = 'auto',
    width = NULL, height = NULL, ...
) {

    xlab = autoArgLabel(x, deparse(substitute(x)))
    ylab = autoArgLabel(y, deparse(substitute(y)))

    x = evalFormula(x, data)
    y = evalFormula(y, data)
    if (type == 'auto') type = determineType(x, y)
    if (type == 'bar') {
        x = as.factor(x)
        if (is.null(y)) ylab = 'Frequency'
    }

    series = evalFormula(series, data)
    data_fun = getFromNamespace(paste0('data_', type), 'rechartsX')

    params = structure(list(
        series = data_fun(x, y, series),
        xAxis = list(), yAxis = list()
    ), meta = list(
        x = x, y = y
    ))

    if (!is.null(series)) {
        params$legend = list(data = levels(as.factor(series)))
    }

    chart = htmlwidgets::createWidget(
        'echarts', x = params, width = width, height = height,
        package = 'rechartsX', dependencies = getDependency(type)
    )

    chart %>% eAxis('x', name = xlab) %>% eAxis('y', name = ylab)

}

#' @export
#' @rdname eChart
echart.default = echart.data.frame

#' @export
#' @rdname eChart
eChart = echart
# from the planet of "Duo1 Qiao1 Yi1 Ge4 Jian4 Hui4 Si3" (will die if having to
# press one more key, i.e. Shift in this case)

#' Framework Function to Create An Echarts Object
#'
#' This function is used to produce the skeleton of an Echarts object with default settings.
#' You can then tune the settings using <setEchartWidgets> functions, <aesthetic> functions,
#' and others.
#' @param data data.frame.
#' @param x independent variable(s). Some charts calls for one, some calls for two.
#' @param y dependent variable(s). Most charts calls for one, but some calls for more.
#' @param series data series variables.
#' @param weight In some charts (bar, bubble, line, ...), weight represents the size
#' of the graph elements.
#' @param facet facet variable to divide the canvas. It takes effect in multiple
#' coordinate system charts (e.g., polar coordinate system (pie, radar, ...) and
#' some other charts (e.g., map, tree, ...)).
#' @param t timeline variable. When \code{t} is defined, rechartsX builds a timeline
#' widget to show the changes along with time.
#' @param lat latitude variable (-180 ~ 180) for map/heatmap
#' @param lng longitude variable (-90 ~ 90) for map/heatmap
#' @param type chart type. Now rechartsX supports major types of
#' \itemize{
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_01_Scatterplot.html}{scatter/point/bubble}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_02_Bar.html}{bar/column/histogram}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_03_Line.html}{line/area/curve/wave}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_04_K.html}{candlestick/k}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_05_eventRiver.html}{eventRiver}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_21_Pie.html}{pie/ring/rose}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_22_Funnel.html}{funnel/pyramid}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_23_Radar.html}{radar/spider/star}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_11_Force.html}{force/force_line}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_12_Chord.html}{chord}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_24_Gauge.html}{gauge}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_13_WordCloud.html}{wordCloud}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_14_Venn.html}{venn}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_31_Map.html}{map_world/map_china/map_world_multi/map_china_multi}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_32_Tree.html}{tree/htree/tree_inv/htree_inv}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_33_Treemap.html}{treemap}
#'   \item \href{http://madlogos.github.io/rechartsX/Basic_Plots_15_Heatmap.html}{heatmap}
#' }
#' @param subtype some chart types support subtypes.
#' \describe{
#'   \item{bar/column}{"stack"}
#'   \item{histogram}{c("count","freq","density")}
#'   \item{line/area}{c("stack","smooth","dotted","solid","dashed")}
#'   \item{curve/wave}{c("stack","solid")}
#'   \item{map_world/world_map/map_world_multi/world_map_multi}{c("sum","average",
#'   [Valid Country Names])}
#'   \item{map_china/china_map/map_china_multi/china_map_multi}{c("sum","average",
#'   [Valid China Province Names])}
#'   \item{pie}{c("multi","clock","clockwise")}
#'   \item{ring}{c("info","multi","clock","clockwise")}
#'   \item{rose}{c("area","radius","multi","clock","clockwise")}
#'   \item{chord}{c("ribbon","scale","scaletext","rotatelab","hidelab","clock",
#'   "clockwise","asc","desc","ascsub","descsub")}
#'   \item{force/force_line}{c("arrow","triangle")}
#'   \item{funnel/pyramid}{c("left","center","right")}
#'   \item{tree/vtree/htree/tree_inv/vtree_inv/htree_inv}{c("curve","broken",
#'   "dotted","solid","dashed")}
#'   \item{radar/spider/star}{"fill"}
#' }
#' @param elementId htmlwidgets elementId of the chart object. If set NULL, rechartsX will
#' assign a random elementId to the object.
#' @param ... Elipsis
#'
#' @import compiler
#' @export
#' @references
#' Online Manual: \url{http://madlogos.github.io/rechartsX}
echartr = function(
    data, x = NULL, y = NULL, series = NULL, weight = NULL, facet = NULL,
    t = NULL, lat = NULL, lng = NULL, type = 'auto', subtype = NULL,
    elementId = NULL, ...
) {
    options(encoding="native.enc")
    if (is.null(data)){
        data <- data.frame(x='', stringsAsFactors=FALSE)
        dataVars <- list('x')
        xvarRaw <- 'x'
        hasT <- FALSE
        xlab <- ylab <- ''
    }else{
        lapply(seq_along(names(data)), function(j){
            if (is.character(data[,j]))
                data[,j] <- enc2native(data[,j])
        })
        if (inherits(data, 'data.frame')) data <- as.data.frame(data)

        #------------- get all arguments as a list-----------------
        vArgs <- as.list(match.call(expand.dots=TRUE))
        dataVars <- intersect(names(vArgs),
                              c('x', 'y', 't', 'series', 'weight', 'facet', 'lat', 'lng'))
        vArgsRaw <- vArgs[dataVars]  # original arg names
        vArgs <- lapply(vArgsRaw, function(v) {
            symbols = all.names(v)
            if (any(symbols %in% names(data)))
                return(as.symbol(symbols[symbols %in% names(data)]))
            # should be sapply(symbols[symbols %in% names(data)], as.symbol)
            v
        })  # get arg names correspond to data vars

        # ------------extract var names and values-----------------
        eval(parse(text=paste0(names(vArgs), "var <- evalVarArg(",
                               sapply(vArgs, deparse), ", data, eval=FALSE)")))
        eval(parse(text=paste0(names(vArgs), "varRaw <- evalVarArg(",
                               sapply(vArgsRaw, deparse), ", data, eval=FALSE)")))
        eval(parse(text=paste0(names(vArgsRaw), " <- evalVarArg(",
                               sapply(vArgsRaw, deparse), ", data)")))
        hasT <- ! is.null(t)
        if (!is.null(series))
            for (i in seq_along(seriesvar))
                if (!is.factor(data[,seriesvar[i]]))
                    data[,seriesvar[i]] = as.factor(data[,seriesvar[i]])

        # ------------------x, y lab(s)----------------------------
        #xlab = ylab = NULL
        if (!missing(x)) xlab = as.character(vArgsRaw$x) else xlab = "x"
        if (!missing(y)) ylab = as.character(vArgsRaw$y) else ylab = "Freq"
        xlab = sapply(xlab, autoArgLabel, auto=deparse(substitute(xvar)))
        ylab = sapply(ylab, autoArgLabel, auto=deparse(substitute(xvar)))
        xlab <- gsub("^\"|\"$", "", xlab)
        ylab <- gsub("^\"|\"$", "", ylab)
        if (length(ylab) == 0) ylab = "Freq"
    }

    # -------------split multi-timeline df to lists-----------

    .makeMetaDataList <- cmpfun(function(df) {
         vars <- sapply(dataVars, function(x) {
             eval(parse(text=paste0(x, 'varRaw')))}, simplify=TRUE)
         if (!is.null(dim(vars)))
             vars <- paste0(
                 'c(',apply(vars, 2, function(x) paste(x, collapse=',')), ')')
         assignment <- paste0(dataVars, " = evalVarArg(", vars, ", ",
                             substitute(df, parent.frame()), ")")
        # assignment <- paste0(dataVars, " = evalVarArg(", vArgsRaw[dataVars], ", ",
        #                      substitute(df, parent.frame()), ")")
        eval(parse(text=paste0("list(", paste(assignment, collapse=", "), ")")))
    })
    if (hasT){
        uniT <- unique(t[,1])
        if (is.factor(uniT)) uniT <- as.character(uniT)
        tSize <- unique(table(data[,tvar]))

        # timeslices not in equal size across t, suppl it
        if (length(tSize) > 1 && is.character(x[,1])) {
            expandData <- data.frame(expand.grid(unique(x[,1]), unique(t[,1]),
                                                 stringsAsFactors=FALSE))
            names(expandData) <- c(xvar[1], tvar[1])
            data <- merge(expandData, data, all.x=TRUE, sort=FALSE)
            data <- data[order(data[,tvar[1]]),]
        }

        dataByT <- split(data, as.factor(data[,tvar[1]]))
        metaData <- lapply(dataByT, .makeMetaDataList)
        names(metaData) <- uniT
        if (! identical(unique(t[,1]), sort(unique(t[,1]))) &&
            ! identical(unique(t[,1]), sort(unique(t[,1]), TRUE)))
            warning("t is not in order, the chart may not show properly!")
    }else{
        metaData <- .makeMetaDataList(data)
    }

    # -----------------determine types---------------------------
    check.types <- unname(sapply(c('auto', validChartTypes$name), grepl,
                                 x=tolower(unlist(type))))
    if (is.null(dim(check.types)))
        check.types <- matrix(check.types, nrow=1)
    if (!any(check.types))
        stop("Invalid chart type!\n", paste(type[which(rowSums(check.types)==0)], ', '),
             " not matching the valid chart type table.")

    if (!is.null(series)) lvlSeries <- levels(as.factor(series[,1]))
    if (!is.null(series)) nSeries <- length(lvlSeries) else nSeries <- 1
    if (type[[1]] == 'auto')  type = determineType(x[,1], y[,1])

    ## type vector: one series, one type
    type = matchTypeList(
        if ('facet' %in% dataVars) facet[,1] else NULL,
        if ('series' %in% dataVars) series[,1] else NULL, type)

    ## special: geoJSON map, not working
    geoJSON <- NULL
    if (any(type == 'map'))
        if (all(! grep('.+[Jj][Ss][Oo][Nn]$', subtype))) {
            stop('When type is "map", geoJSON file must be provided in subtype')
        }else{
            if (grep('.+[Jj][Ss][Oo][Nn]$', subtype) > 1)
                warning('echartr only accepts the first geoJSON file.')
            geoJSON <- subtype[grep('.+[Jj][Ss][Oo][Nn]$', subtype)][1]
            con <- system.file('htmlwidgets/lib/echarts/ext/loadGeoJSON.js',
                               package='rechartsX')
            paramPath <- system.file('htmlwidgets/lib/echarts/ext',
                                     package='rechartsX')
            if (file.exists(con)){
                writeLines(paste0(
                    "require('", paramPath, "/param').params.newmap = { ",
                    "getGeoJson: function (callback) { ",
                    "$.getJSON('", geoJSON, "',callback);","}})"),
                    con)
            }
        }

    ## subtype
    if (!missing(subtype)) if (length(subtype) > 0)
        subtype = matchTypeList(
            if ('facet' %in% dataVars) facet[,1] else NULL,
            if ('series' %in% dataVars) series[,1] else NULL, subtype)
#browser()
    ## type is converted to a data.frame, colnames:
    ## [id name type stack smooth mapType mapMode misc]
    dfType <- sapply(validChartTypes$name, function(x) grepl(x, unlist(type)))
    if (is.null(dim(dfType))){
        typeIdx <- unname(which(dfType))
    }else{
        typeIdx <- unname(unlist(sapply(seq_len(nrow(dfType)),
                                 function(i) which(dfType[i,]))))
    }
    dfType <- validChartTypes[typeIdx,]
    lstSubtype <- rep('', length(unlist(type)))
    if (!missing(subtype)) if (length(subtype) > 0)
        lstSubtype <- lapply(1:length(unlist(subtype)), function(i){
            str <- unlist(subtype)[i]
            validSubtype <- eval(parse(text=tolower(dfType[i, 'subtype'])))
            strSubtype <- unlist(strsplit(str, '[_|\\+]'))
            strSubtype <- gsub("^ +| +$", "", strSubtype)
            jsonFile <- strSubtype[grepl("\\.[Jj][Ss][Oo][Nn]$", strSubtype)]
            o <- intersect(validSubtype, strSubtype)
            if (length(jsonFile) > 0) o <- c(o, jsonFile)
            if (length(o) == 0) o <- ''
            return(o)
        })

    ## check types
    if (nlevels(as.factor(dfType$type)) > 1){
        if (!all(grepl("^(line|bar|hist|scatter|k)", dfType$type) ||
                 grepl("^(funnel|pie)", dfType$type) ||
                 grepl("^(force|chord)", dfType$type) ||
                 grepl("^(tree|treemap)", dfType$type)))
            stop(paste("rechartsX does not support such mixed types yet."))
    }

    # if (nlevels(as.factor(dfType$xyflip)) > 1)
    #     warning(paste("xyflip is not consistent across the types given.\n",
    #                   dfType[, "xyflip"]))

    # ---------------------------params list----------------------
    .makeSeriesList <- cmpfun(function(t){  # each timeline create a options list
        #browser()
        series_fun = getFromNamespace(paste0('series_', dfType$type[1]),
                                    'rechartsX')

        if (is.null(t)){  # no timeline
            time_metaData = lapply(metaData, function(df){
                data.frame(lapply(df, function(col) {
                    if (inherits(col, c("Date", "POSIXlt", "POSIXlt")))
                        col = convTimestamp(col)
                    return(col)
                }))
            })
            out <- structure(list(
                series = series_fun(time_metaData, type=dfType, subtype=lstSubtype)
            ), meta = metaData)
        }else{  # with timeline
            time_metaData = lapply(metaData, function(df){
                lapply(df, function(col) {
                    if (inherits(col, c("Date", "POSIXlt", "POSIXlt")))
                        col = convTimestamp(col)
                    return(col)
                })
            })
            out <- structure(list(
                series = series_fun(time_metaData[[t]], type=dfType,
                                    subtype=lstSubtype, fullMeta=metaData)
            ), meta = metaData[[t]])
        }

        return(out)
    })

    if (hasT){  ## has timeline
        params = list(
            timeline=structure(list(), sliceby=tvar),
            options=lapply(1:length(uniT), .makeSeriesList)
        )
        if (!is.null(series))
            params$options[[1]]$legend <- list(
                data = as.list(levels(as.factor(series[,1])))
            )
    }else{
        params = .makeSeriesList(NULL)
        if (!is.null(series))
            params$legend <- list(
                data = as.list(levels(as.factor(series[,1])))
            )
    }

    # -------------------output-------------------------------
    chart = htmlwidgets::createWidget(
        'echarts', params, width = NULL, height = NULL, package = 'rechartsX',
        dependencies = NULL
    )

    if (hasT) chart <- chart %>% setTimeline(show=TRUE, data=uniT)
    if (!is.null(geoJSON)) chart$geoJSON <- geoJSON

    if (any(dfType$type %in% c('map'))){
        chart <- chart %>% setTooltip() %>% setToolbox() %>% setLegend()
    }else if (any(dfType$type %in% c('heatmap'))){
        chart <- chart %>% setXAxis(show=FALSE) %>% setYAxis(show=FALSE) %>%
            setGrid(borderWidth=0)
    }else if (any(dfType$type %in% c('line', 'bar', 'hist', 'scatter', 'k', 'eventRiver'))){
        if (!any(dfType$type %in% c('eventRiver')))
            chart <- chart %>% setYAxis(name = ylab[[1]])
        chart <- chart %>% setXAxis(name = xlab[[1]]) %>%
            setTooltip() %>% setToolbox() %>% setLegend() %>%
            flipAxis(flip=any(grepl("flip", dfType$misc)))
    }else{
        chart <- chart %>% setXAxis(show=FALSE) %>%
            setYAxis(show=FALSE) %>% setGrid(borderWidth=0) %>%
            setTooltip() %>% setToolbox() %>% setLegend() %>%
            autoPolar(type=dfType)
    }
    if (!is.null(elementId)) chart$elementId = elementId
    chart
}

#' @export
#' @rdname echartr
echartR <- echartr

determineType = function(x, y) {
    if (is.numeric(x) && is.numeric(y)) return('scatter')
    # when y is numeric, plot y against x; when y is NULL, treat x as a
    # categorical variable, and plot its frequencies
    if ((is.factor(x) || is.character(x)) && (is.numeric(y) || is.null(y)))
        return('bar')
    if (is.null(x) && is.ts(y)) return('line')
    # FIXME: 'histogram' is not a standard plot type of ECharts
    # http://echarts.baidu.com/doc/doc.html
    if ((is.numeric(x) && is.null(y)) || (is.numeric(y) && is.null(x)))
        return('histogram')
    message('The structure of x:')
    str(x)
    message('The structure of y:')
    str(y)
    stop('Unable to determine the chart type from x and y automatically')
}

# not usable yet; see https://github.com/ecomfe/echarts/issues/1065
getDependency = function(type) {
    if (is.null(type)) return()
    htmltools::htmlDependency(
        'echarts-module', EChartsVersion,
        src = system.file('htmlwidgets/lib/echarts', package = 'rechartsX'),
        script = sprintf('%s.js', type)
    )
}

getMeta = function(obj) {
    if (inherits(obj, "echarts"))
        attr(obj$x, 'meta', exact = TRUE)
    else
        attr(obj, "meta", exact = TRUE)
}

matchTypeList = function(facet, series, param, lower.case=TRUE){
    stopifnot(is.vector(param) || is.list(param))
    stopifnot(is.null(facet) || is.vector(facet) || is.factor(facet))
    stopifnot(is.null(series) || is.vector(series) || is.factor(series))

    if (is.null(facet)){  # no facets
        if (is.list(param)) param = unlist(param)
        if (is.null(series)){
            param = casefold(param[1], !lower.case)
        }else{
            if (length(param) >= length(unique(series))){
                param = casefold(param[1:length(unique(series))], !lower.case)
            }else{
                param = casefold(
                    c(param, rep(param[length(param)],
                                 length(unique(series)) - length(param))),
                    !lower.case)
            }
        }
    }else{  # with facets
        if (!is.list(param)) param = list(param)
        if (length(param) >= length(unique(facet)))
            param = param[1:length(unique(facet))]
        else
            param = append(param, rep(param[length(param)],
                                      length(unique(facet)) - length(param)))
        if (is.null(series)){
            for (i in 1:length(param))
                param[[i]] = casefold(param[[i]][1], !lower.case)
        }else{
            for (i in 1:length(param)){  # suppl params
                if (length(param[[i]]) >= length(unique(series))){
                    param[[i]] = casefold(param[[i]][1:length(unique(series))],
                                          !lower.case)
                }else{
                    param[[i]] = casefold(
                        c(param[[i]], rep(
                            param[[i]][length(param[[i]])],
                            length(unique(series)) - length(param[[i]]))),
                        !lower.case)
                }
            }
        }
    }
    return(param)
}
