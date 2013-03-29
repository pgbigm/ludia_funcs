-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION ludia_funcs" to load this file. \quit

CREATE FUNCTION pgs2textporter1(text)
RETURNS text
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT VOLATILE;

CREATE FUNCTION pgs2snippet1(integer, integer, integer,
			  text, text, integer, text, text)
RETURNS text
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION pgs2norm(text)
RETURNS text
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;

CREATE FUNCTION pgs2seninfo(OUT version text,
			  OUT configure_options text)
RETURNS record
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT IMMUTABLE;
