var source = './app';
var destination = '../../../artifacts/17.2/Inventory/debug/app';

var gulp = require('gulp');
var requireDir  = require('require-dir');

requireDir('./gulp/tasks', {recurse: false});