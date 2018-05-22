(function (a) {
    var e, i, input, filename, defaults;
    if (!a[0]) {
        print("Usage: jslint.js file.js ...");
        quit(1);
    }

    defaults = {
	predef: ['Ext', 'PVE', 'PMG', 'PVE_vnc_console_event', 'FormData', 'gettext', 'Proxmox'],
	devel:      true,
	'continue': true,   /// Allow continue statement
	bitwise:    true,   //  Allow bitwise operators
        browser:    true,   //  Assume a browser 
        css:        true,   //  Tolerate CSS workarounds
        eqeq:       true,   //  Allow `==` && `!=`
        //immed:      true,  //  Immediate invocations must be wrapped in parens.
        //nomen:      true,  //  Allow dangling `_` in identifiers
        newcap:     false,   //  Require initial caps for constructors
        vars:       true,   //  Allow multiple `var` statements.
        plusplus:   true,   //  Allow `++` and `--`
        regexp:     true,  //   Allow `.` and `[^...]` in regex
        sloppy:     true,   //  Don't require `use strict;`
        undef:      false,  //  Disallow undeclared variables 
        white:      true    //  Don't apply strict whitespace rules
    };
    
    for (i = 0; i < a.length; ++i) {
    	filename = a[i];
	input = readFile( filename );
	if (!input) {
            print("jslint: Couldn't open file '" + filename + "'.");
            quit(1);
	}

	if (!JSLINT(input, defaults)) {
            for (i = 0; i < JSLINT.errors.length; i += 1) {
		e = JSLINT.errors[i];
		if (e) {
                    print('[' + filename + '] Lint at line ' + e.line + ' character ' +
                          e.character + ': ' + e.reason);
                    print((e.evidence || '').
                          replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1"));
                    print('');
		}
            }
            quit(2);
	} else {
            print("jslint: " + filename + " OK");
	}
    }
    quit();
}(arguments));
