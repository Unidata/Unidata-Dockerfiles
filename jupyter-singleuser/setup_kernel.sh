#!/bin/bash

source activate $@
ipython kernelspec install-self
