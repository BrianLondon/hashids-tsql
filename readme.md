# Hashids
A small set of TSQL functions to generate YouTube-like hashes from one or many numbers. 
Use hashids when you do not want to expose your database ids to the user.

[http://www.hashids.org/](http://www.hashids.org/)

## What is it?

hashids (Hash ID's) creates short, unique, decryptable hashes from unsigned integers.

This project is a port to TSQL of the other projects found via [http://www.hashids.org/](http://www.hashids.org/).
The .NET and Javascript versions of Hashids are the primary reference projects for this port.

## Status

The SQL functions generated by hashids-tsql can currently encode numbers, but not decode them. The mssql database 
project (called HashidsTsql) contains 3 functions: consistentShuffle, encode1 and hash. To generate a new encode1 
function with your custom salt, use the hashids-tsql generator.

## TSQL Function Naming

TSQL does not have function overloading, so the single `encode` function that is common in other hashids.org libraries
is instead represented here as a set of `encode` functions with slight variations in name, declaration and possibly even
return value.

The basic forms of `encode` for TSQL are:

- `encode1(int) string`
- `encode2(int, int) string`
- `encodeSplit(string, string) string`
- `encodeTable(table) string`

In TSQL, the `encode` functions that take 1 or 2 integers will be much more useful than the one that takes a table
because typically, you don't want to construct a table variable just to pass 1 or 2 integers into a function.
   
## TODO

- Create `encodeTable` functions.
- Create `encodeSplit` functions that split a string/delimiter and return the `encodeTable` result.
- Create TSQL functions for decoding and integrate them into the hashids-tsql generator.
- See other minor technical TODO items in hashids-tsql/app.js.