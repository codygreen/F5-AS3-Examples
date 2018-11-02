# send traffic to canary pool
when HTTP_REQUEST {
    # check for canary
    if { [HTTP::header exists "canary_percentage"] && [HTTP::header exists "canary_pool"] } {
        # set canary value
        set c 0.[HTTP::header canary_percentage]
        HTTP::header insert "test" $c
        if { rand() < $c || [HTTP::header "canary"] eq "true" } {
            pool [HTTP::header value "canary_pool"]
        }
    }
}

# remove canary information
when HTTP_RESPONSE {
    if {[HTTP::header exists "canary_percentage"]} {
        HTTP::header remove "canary_percentage"
    }
    if {[HTTP::header exists "canary_pool"]} {
        HTTP::header remove "canary_pool"
    }
}