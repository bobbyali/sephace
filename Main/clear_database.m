% clear database
clear all
close all
clc

mksqlite('open','sephaCe.db');
mksqlite('delete from data');
mksqlite('delete from experiments');
mksqlite('delete from tasks');
mksqlite('close');
disp('sephaCe database cleared');