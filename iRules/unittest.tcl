# provide unit test capabilities for Local Traffic Policies
when HTTP_REQUEST {
    if { [HTTP::header exists "unittest"] } {
        log local0. "##################################################################################"
        # Log the policy controls enabled on this virtual server
    	log local0. "\[POLICY::controls\]: [POLICY::controls]"
    
        log local0. "#############################################"
    	# Loop through each possible control type and log whether it is enabled or not (1 for enabled, 0 for not enabled)
    	foreach control {acceleration asm avr caching classification compression forwarding l7dos request-adaptation response-adaptation server-ssl} {
    		log local0. "\[POLICY::controls $control\]: [POLICY::controls $control]"
    	}
    	log local0. "Enabled on this VS: \[POLICY::names active\]: [POLICY::names active]"
    	log local0. "Matched: \[POLICY::names matched\]: [POLICY::names matched]"
    	log local0. "Not matched: \[POLICY::names unmatched\]: [POLICY::names unmatched]"
    	
    	log local0. "#############################################"
    	log local0. "Looping through \[POLICY::names matched\]: [POLICY::names matched]"
    	append payload "Policies matched:" [POLICY::names matched] "\r\n"
    	
    	foreach policy [POLICY::names matched] {
    		log local0. "\[POLICY::rules matched $policy\]: [POLICY::rules matched $policy]"
    		append payload "rules matched:" [POLICY::rules matched $policy]  "\r\n"
    	}
    	
    	log local0. "#############################################"
    	# Log the policy targets enabled on this virtual server
    	log local0. "\[POLICY::targets\]: [POLICY::targets]"
    
    	# Loop through each possible target type and log whether it is enabled or not (1 for enabled, 0 for not enabled)
    	foreach target {asm wam log http-cookie http-header http-host http-referer http-set-cookie http-uri log tcl tcp-nagle} {
    		log local0. "\[POLICY::targets $target\]: [POLICY::targets $target]"
    	}
    	log local0. "##################################################################################"
    	
    	# display unit test information
    	HTTP::respond 200 content $payload
    }
}