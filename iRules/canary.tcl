# send traffic to canary pool

# detects if the prefered pool has active members and chooses the correct pool
proc selectPool { select_pool backup_pool } {
    # determine if pool has active members
    if { [active_members $select_pool] < 1 } {
        log local0.error "selectPool Error: selected pool has no active members"
        pool $backup_pool
        return false
    } else {
        pool $select_pool
        return true
    }
}

when HTTP_REQUEST {
    set canary_cookie_name "canary"
    set canary_percentage_header_name "canary_percentage"
    set canary_pool_header_name "canary_pool"
    set canary_cookie_value "null"

    # check if virtual server is configured for canary
    if { [HTTP::header exists $canary_percentage_header_name] && [HTTP::header exists $canary_pool_header_name] } {
        # set canary variables
        set canary_percentage [HTTP::header value $canary_percentage_header_name]
        set canary_pool [HTTP::header value $canary_pool_header_name]
        set current_pool [LB::server pool]
    
        # check for canary cookie
        if { [HTTP::cookie exists $canary_cookie_name]} {
            switch [HTTP::cookie value $canary_cookie_name] {
                "canary" {
                    call selectPool $canary_pool $current_pool
                }
                "default" {
                    pool $current_pool
                }
            }
        } else {
            # set canary value
            set c 0.[HTTP::header canary_percentage]
            # check if there is a static canary header or if the user falls
            # into the random percentage of canary users
            if { rand() < $c || [HTTP::header "canary"] eq "true" } {
                log local0. "CANARY REQUEST INITIALIZED"
                set canary_cookie_value "canary"
                call selectPool $canary_pool $current_pool
            } else {
                log local0. "NON-CANARY REQUEST INITIALIZED"
                set canary_cookie_value "default"
                pool $current_pool
            }
        }
    }
}

# remove canary information
when HTTP_RESPONSE {
    if { $canary_cookie_value ne "null" } {
        HTTP::cookie insert name $canary_cookie_name value $canary_cookie_value path "/"
    }
    
    if {[HTTP::header exists $canary_percentage_header_name]} {
        HTTP::header remove $canary_percentage_header_name
    }
    if {[HTTP::header exists $canary_pool_header_name]} {
        HTTP::header remove $canary_pool_header_name
    }
}