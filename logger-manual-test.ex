-- logger-manual-test.ex

include lib/utils/bzlog.e
  
function main()  
    
    verbose()
    tracelog()
    debug()
    info()
    err()
    silent()
    puts(1, "Test Completed")
    
    return 1
end function

procedure writeLogs(TBzLog o)
    bzlog:write(o, VERBOSE,  "VERBOSE message")
    bzlog:write(o, TRACE,    "TRACE message")
    bzlog:write(o, DEBUG,    "DEBUG message")
    bzlog:write(o, INFO,     "INFO message")
    bzlog:write(o, ERR,      "ERR message\n")
    bzlog:write(o, SILENT,   "SILENT message")
end procedure


procedure verbose()
    TBzLog olog = bzlog:new( VERBOSE, "logger_test.log" )  
    bzlog:write(olog, VERBOSE, "Starting logger in VERBOSE")
    writeLogs(olog)
    bzlog:free(olog)
end procedure

procedure tracelog()
    TBzLog olog = bzlog:new( TRACE, "logger_test.log" )  
    bzlog:write(olog, TRACE, "Starting logger in TRACE")
    writeLogs(olog)
    bzlog:free(olog)
end procedure

procedure debug()
    TBzLog olog = bzlog:new( DEBUG, "logger_test.log" )  
    bzlog:write(olog, DEBUG, "Starting logger in DEBUG")
    writeLogs(olog)
    bzlog:free(olog)
end procedure

procedure info()
    TBzLog olog = bzlog:new( INFO, "logger_test.log" )  
    bzlog:write(olog, INFO, "Starting logger in INFO")
    writeLogs(olog)
    bzlog:free(olog)
end procedure

procedure err()
    TBzLog olog = bzlog:new( ERR, "logger_test.log" )  
    bzlog:write(olog, ERR, "Starting logger in ERR")
    writeLogs(olog)
    bzlog:free(olog)
end procedure

procedure silent()
    TBzLog olog = bzlog:new( SILENT, "logger_test.log" )  
    bzlog:write(olog, SILENT, "Starting logger in SILENT")
    writeLogs(olog)
    bzlog:free(olog)
end procedure

main()
