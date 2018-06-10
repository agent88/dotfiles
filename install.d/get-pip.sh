#!/bin/bash
#

function INSTALL_PIP {
	curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
	sudo python3 /tmp/get-pip.py
	pip install -U pip
}
