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


setClass(Class = "MxFitFunctionR",
	representation = representation(
		fitfun = "function",
		model = "MxModel",
		flatModel = "MxFlatModel",
		parameters = "list",
		state = "list"),
	contains = "MxBaseFitFunction")

setMethod("initialize", "MxFitFunctionR",
	function(.Object, fitfun, state,  name = 'fitfunction') {
		.Object@fitfun <- fitfun
		.Object@name <- name
		.Object@state <- state
		.Object@expectation <- as.integer(NA)
		return(.Object)
	}
)

setMethod("genericFitFunConvert", signature("MxFitFunctionR"), 
	function(.Object, flatModel, model, labelsData, defVars, dependencies) {
		.Object@model <- model
		.Object@flatModel <- flatModel
		.Object@parameters <- generateParameterList(flatModel, dependencies)
		return(.Object)
})

setMethod("genericFitFunNamespace", signature("MxFitFunctionR"), 
	function(.Object, modelname, namespace) {
		.Object@name <- imxIdentifier(modelname, .Object@name)
		return(.Object)
})

setMethod("genericFitAddEntities", signature("MxFitFunctionR"),
	function(.Object, job, flatJob, labelsData) {
		job@.forcesequential <- TRUE
		return(job)
})

mxFitFunctionR <- function(fitfun, ...) {
	if (!is.function(fitfun)) {
		stop("First argument 'fitfun' must be of type function")
	}
	if (length(formals(fitfun)) != 2) {
		stop("The fit function must take exactly two arguments: a model and a persistant state")
	}
	state <- list(...)
	return(new("MxFitFunctionR", fitfun, state))
}

displayRFitFun <- function(fitfunction) {
	cat("MxFitFunctionR", omxQuotes(fitfunction@name), '\n')
	cat("@fitfun (fitness function) \n")
	print(fitfunction@fitfun)
	if (length(fitfunction@result) == 0) {
		cat("@result: (not yet computed) ")
	} else {
		cat("@result:\n")
	}
	print(fitfunction@result)
	invisible(fitfunction)
}


setMethod("print", "MxFitFunctionR", function(x,...) { 
	displayRFitFun(x) 
})

setMethod("show", "MxFitFunctionR", function(object) { 
	displayRFitFun(object) 
})