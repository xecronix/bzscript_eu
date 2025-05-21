-- File: bzs.eu
-- Main entry point for BZScript in Euphoria
-- Usage: eui bzs.eu scripts/demo.bzs
with trace
include std/io.e
include std/console.e
include std/filesys.e
include std/get.e
include lib/shared/constants.e
include lib/utils/logger.e

procedure main()
    init_logger()
    logger(DEBUG, "Starting main")
    sequence cmd_args = command_line()
    
    -- We expect the 3rd argument to be the script path:
    --   cmd_args[1] = interpreter (eui)
    --   cmd_args[2] = this file (bzs.eu)
    --   cmd_args[3] = script path (scripts/demo.bzs)
    if length(cmd_args) < 3 then
        puts(1, "Usage: eui bzs.ex <script.bzs>\n")
        abort(1)
    end if

    sequence script_path = cmd_args[3]

    -- Check file exists
    if not file_exists(script_path) then
        printf(1, "Error: File not found: %s\n", {script_path})
        abort(1)
    end if

    -- Read file contents
    integer fn = open(script_path, "r")
    if fn = -1 then
        printf(1, "Error: Failed to open file: %s\n", {script_path})
        abort(1)
    end if

    sequence source = read_file(fn)
    close(fn)

    -- TODO: Tokenize, categorize, run...
    logger(DEBUG, "End of Main")
    close_logger()
    puts(1, "BZScript Ended Normally.\n")
end procedure

main()
