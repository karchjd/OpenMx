#
#   Copyright 2007-2012 The OpenMx Project
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


#
# The virtual base class for all fit functions
#
setClass(Class = "MxBaseFitFunction", 
	representation = representation(
		name = "character",
        info = "list",
		dependencies = "integer",
		expectation = "integer",
		result = "matrix", "VIRTUAL"))

setClassUnion("MxFitFunction", c("NULL", "MxBaseFitFunction"))

setGeneric("genericFitDependencies",
	function(.Object, flatModel, dependencies) {
	return(standardGeneric("genericFitDependencies"))
})

setGeneric("genericFitFunNamespace", 
	function(.Object, modelname, namespace) {
	return(standardGeneric("genericFitFunNamespace"))
})

setGeneric("genericFitRename",
	function(.Object, oldname, newname) {
	return(standardGeneric("genericFitRename"))
})

setGeneric("genericFitInitialMatrix",
	function(.Object, flatModel) {
	return(standardGeneric("genericFitInitialMatrix"))
})

setGeneric("genericFitNewEntities",
	function(.Object) {
	return(standardGeneric("genericFitNewEntities"))
})


setGeneric("genericFitFunConvert", 
	function(.Object, flatModel, model, labelsData, defVars, dependencies) {
	return(standardGeneric("genericFitFunConvert"))	
})

setMethod("genericFitInitialMatrix", "MxBaseFitFunction",
	function(.Object, flatModel) {
		return(matrix(as.double(NA), 1, 1))
})

setMethod("genericFitInitialMatrix", "NULL",
	function(.Object, flatModel) {
		return(NULL)
})

##' Add dependencies
##'
##' If there is an expectation, then the fitfunction should always
##' depend on it. Hence, subclasses that implement this method must
##' ignore the passed-in dependencies and use "dependencies <-
##' callNextMethod()" instead.
##'
##' @param .Object
##' @param flatModel
##' @param dependencies accumulated dependency relationships

setMethod("genericFitDependencies", "MxBaseFitFunction",
	function(.Object, flatModel, dependencies) {
        name <- .Object@name
        modelname <- imxReverseIdentifier(model, .Object@name)[[1]]
        expectName <- paste(modelname, "expectation", sep=".")
        if (!is.null(flatModel[[expectName]])) {
            dependencies <- imxAddDependency(expectName, .Object@name, dependencies)
        }
		return(dependencies)
})

setMethod("genericFitDependencies", "NULL",
	function(.Object, flatModel, dependencies) {
		return(dependencies)
})

setMethod("genericFitRename", "MxBaseFitFunction",
	function(.Object, oldname, newname) {
		return(.Object)
})

setMethod("genericFitRename", "NULL",
	function(.Object, oldname, newname) {
		return(NULL)
})

setMethod("genericFitNewEntities", "MxBaseFitFunction",
	function(.Object) {
		return(NULL)
})

setGeneric("genericFitConvertEntities",
	function(.Object, flatModel, namespace, labelsData) {
	return(standardGeneric("genericFitConvertEntities"))
})

setGeneric("genericFitAddEntities",
	function(.Object, job, flatJob, labelsData) {
	return(standardGeneric("genericFitAddEntities"))
})

setMethod("genericFitConvertEntities", "MxBaseFitFunction",
	function(.Object, flatModel, namespace, labelsData) {
		return(flatModel)
})

setMethod("genericFitConvertEntities", "NULL",
	function(.Object, flatModel, namespace, labelsData) {
		return(flatModel)
})

setMethod("genericFitAddEntities", "MxBaseFitFunction",
	function(.Object, job, flatJob, labelsData) {
		return(job)
})

setMethod("genericFitAddEntities", "NULL",
	function(.Object, job, flatJob, labelsData) {
		return(job)
})

fitFunctionAddEntities <- function(model, flatModel, labelsData) {

	fitfunctions <- flatModel@fitfunctions

	if (length(fitfunctions) == 0) {
		return(model)
	}

	for(i in 1:length(fitfunctions)) {
		model <- genericFitAddEntities(fitfunctions[[i]], model, flatModel, labelsData)
	}

	return(model)
}

fitFunctionModifyEntities <- function(flatModel, namespace, labelsData) {

	fitfunctions <- flatModel@fitfunctions

	if (length(fitfunctions) == 0) {
		return(flatModel)
	}

	for(i in 1:length(fitfunctions)) {
		flatModel <- genericFitConvertEntities(fitfunctions[[i]], flatModel, namespace, labelsData)
	}

	return(flatModel)
}

convertFitFunctions <- function(flatModel, model, labelsData, defVars, dependencies) {
	retval <- lapply(flatModel@fitfunctions, genericFitFunConvert, 
		flatModel, model, labelsData, defVars, dependencies)
	return(retval)
}

fitFunctionReadAttributes <- function(fitFunction, values) {
        attr <- attributes(values)
        attributes(values) <- list('dim' = attr$dim)

		dimnames(values) <- dimnames(fitFunction)
        attr$dim <- NULL

		fitFunction@result <- values
        fitFunction@info <- attr
		return(fitFunction)
}