#!/bin/sh
nohup rake assets:precompile &
nohup rails s &
