-- logger.e

-- 📄 File: lib/utils/logger.e

include std/io.e
include std/filesys.e
include std/sequence.e
include std/datetime.e
include ../shared/constants.e

global enum SILENT, ERR, INFO, DEBUG, TRACE, VERBOSE

integer log_level = VERBOSE
sequence log_file = "bzscript.log"
integer log_handle = -1


-- Open the log file for appending
global procedure init_logger()
    if not file_exists(log_file) then
        log_handle = open(log_file, "w")
    else
        log_handle = open(log_file, "a")
    end if
    if log_handle = -1 then
        puts(1, "[logger] Failed to open log file.\n")
        abort(1)
    end if
end procedure

-- Close the log file on exit
global procedure close_logger()
    if log_handle != -1 then
        close(log_handle)
        log_handle = -1
    end if
end procedure

-- Internal logging function
procedure log_line(sequence level, sequence msg)
    sequence td = format(now(), "%Y-%m-%d %k:%M:%S")
    printf(log_handle, "[%s] [%s] %s\n", {td, level, msg})
end procedure

-- Public log APIs
procedure log_info(sequence msg)
    log_line("info", msg)
end procedure

procedure log_debug(sequence msg)
    log_line("debug", msg)
end procedure

procedure log_trace(sequence msg)
    log_line("trace", msg)
end procedure

procedure log_error(sequence msg)
    log_line("error", msg)
end procedure


procedure log_verbose(sequence msg)
    log_line("verbose", msg)
end procedure

global procedure logger(integer level, sequence msg)
    -- SILENT, ERR, INFO, DEBUG, TRACE, VERBOSE
    if log_handle = -1 then
        init_logger()
    end if
    if level <= log_level then
        if level  = SILENT  then
            -- do nothing
            elsif level = ERR then
                log_error(msg)
            elsif level = INFO then
                log_info(msg)
            elsif level = DEBUG then
                log_debug(msg)
            elsif level = TRACE then
                log_trace(msg)
            elsif level = VERBOSE then
                log_verbose(msg)
            else
                log_error("**INVALID LOGGER TYPE**")
                log_error(msg)
        end if
    end if
end procedure
