#!/bin/bash

DBNAME=$1

psql -c 'create database '$DBNAME';'
psql -d $DBNAME -f logical-schema.sql # setup tables and columns
psql -d $DBNAME -f load-varieties.sql # load external list of varieties
psql -d $DBNAME -f example-views.sql # create views
