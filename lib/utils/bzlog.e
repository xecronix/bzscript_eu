-- bzlog.e
namespace bzlog
include std/eumem.e 
include std/io.e
include std/console.e
include std/filesys.e
include std/get.e 
include std/datetime.e

 
--  
-- this is our structure (let's hide the implementation details) 
--  
enum  
    __TYPE__, -- must be first value in enum 
    _log_level,  
    _log_file,  
    _log_handle,  
    __MYSIZE__ -- must be last value in enum 
 
-- 
-- ID pattern is SOMETHING_THAT_MAKES_SENSE DOLLAR_SYMBOL SOME_RANDOM_CHARS 
--     
constant BZLOG_ID = "BzLog$TES@#&sdfhsfhsaGHSf%^" 
     
-- Create a type checker
public type TBzLog (atom me) 
    if eumem:valid(me, __MYSIZE__) then 
        if equal(eumem:ram_space[me][__TYPE__], BZLOG_ID) then 
            return 1 
        end if 
    end if 
    return 0 
end type 

constant SIZEOF_BZLOG = __MYSIZE__  
public enum SILENT, ERR, INFO, DEBUG, TRACE, VERBOSE     
--  
-- create a new object  
--  
public function new( integer log_level, sequence log_file)  
    
    integer log_handle = -1
    if not file_exists(log_file) then
        log_handle = open(log_file, "w")
    else
        log_handle = open(log_file, "a")
    end if
    if log_handle = -1 then
        puts(1, "[bzlog] Failed to open log file.\n")
        abort(1)
    end if      
    
    return eumem:malloc( {BZLOG_ID, log_level, log_file, log_handle, SIZEOF_BZLOG} )  
end function  

-- public API
public function free(TBzLog me)
    close_logger(me)
    eumem:free(me)
    return 1
end function

-- public API
public procedure write(TBzLog me, integer level, sequence msg)
    -- SILENT, ERR, INFO, DEBUG, TRACE, VERBOSE

    if level <= get_log_level(me) then
        if level  = SILENT  then
            -- do nothing
            elsif level = ERR then
                log_error(me, msg)
            elsif level = INFO then
                log_info(me, msg)
            elsif level = DEBUG then
                log_debug(me, msg)
            elsif level = TRACE then
                log_trace(me, msg)
            elsif level = VERBOSE then
                log_verbose(me, msg)
            else
                log_error(me, "**INVALID LOGGER TYPE**")
                log_error(me, msg)
        end if
    end if
end procedure
 
-- Close the log file on exit
procedure close_logger(TBzLog me)
    integer h = get_log_handle(me)
    if h != -1 then
        close(h)
        set_log_handle(me, -1)
    end if
end procedure

-- private
function get_log_handle(TBzLog me)
    return eumem:ram_space[me][_log_handle]  
end function

-- private
procedure set_log_handle(TBzLog me, integer handle)
    eumem:ram_space[me][_log_handle] = handle
end procedure

-- private
function get_log_level(TBzLog me)
    return eumem:ram_space[me][_log_level]  
end function

-- private
procedure set_log_level(TBzLog me, integer level)
    eumem:ram_space[me][_log_level] = level
end procedure

-- private logging function
procedure log_line(TBzLog me, sequence level, sequence msg)
    sequence td = format(now(), "%Y-%m-%d %k:%M:%S")
    printf(get_log_handle(me), "[%s] [%s] %s\n", {td, level, msg})
end procedure

-- private
procedure log_info(TBzLog me, sequence msg)
    log_line(me, "info", msg)
end procedure

-- private
procedure log_debug(TBzLog me, sequence msg)
    log_line(me, "debug", msg)
end procedure

-- private
procedure log_trace(TBzLog me, sequence msg)
    log_line(me, "trace", msg)
end procedure

-- private
procedure log_error(TBzLog me, sequence msg)
    log_line(me, "error", msg)
end procedure

-- private
procedure log_verbose(TBzLog me, sequence msg)
    log_line(me, "verbose", msg)
end procedure

