########################################################################################
## Customized VCL file for serving up a generic website
##
## Author: Nil Portugués Calderó <contact@nilportugues.com>
## Date: 12/27/15
## Time: 18:27
########################################################################################

backend default {
    .host = "nginx_php7";
    .port = "8000";
}

##------------------------------------------------------------------------------
## Routine used for outgoing requests.
##------------------------------------------------------------------------------
sub vcl_deliver
{
    ##------------------------------------------------------------------------------
    ## Hide some headers
    ##------------------------------------------------------------------------------
    unset resp.http.Accept-Ranges;
    unset resp.http.Via;
    unset resp.http.X-Varnish;
    unset resp.http.Age;
    set resp.http.Accept-Ranges="bytes";

    ##------------------------------------------------------------------------------
    ## Add some headers
    ##------------------------------------------------------------------------------
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
        set resp.http.X-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Cache = "MISS";
    }
}

##------------------------------------------------------------------------------
## Routine used to respond to incoming requests.
##------------------------------------------------------------------------------
sub vcl_recv {
    ##------------------------------------------------------------------------------
    ## Get the machine IP that is forwarding the traffic to the backend.
    ##------------------------------------------------------------------------------
    set req.http.X-Real-Forwarded-For = regsub(client.ip, ":.*", "");

    if (req.restarts == 0) {
        if (req.http.x-forwarded-for) {
            set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
        } else {
            set req.http.X-Forwarded-For = client.ip;
        }
    }

    ##------------------------------------------------------------------------------
    ## Don't cache if it's POST, PUT, PATCH or DELETE
    ##------------------------------------------------------------------------------
    if (req.request != "GET") {
        return (pass);
    }

    ##------------------------------------------------------------------------------
    ## Not cacheable by default is requires Authorization
    ##------------------------------------------------------------------------------
     if (req.http.Authorization) {
         return (pass);
     }


    ##------------------------------------------------------------------------------
    ## Handle compression correctly.
    ##
    ## Different browsers send different "Accept-Encoding" headers, even though they
    ## mostly all support the same compression mechanisms. By consolidating these
    ## compression headers into a consistent format, we can reduce the size of the
    ## cache and get more hits.
    ##
    ## - Firefox, IE: gzip, deflate
    ## - Chrome: gzip,deflate,sdch
    ## - Opera: deflate, gzip, x-gzip, identity, *;q=0
    ##
    ##------------------------------------------------------------------------------
    if (req.http.Accept-Encoding) {
        if (req.http.Accept-Encoding ~ "gzip") {
            # If the browser supports it, we'll use gzip.
            set req.http.Accept-Encoding = "gzip";
        }
        else if (req.http.Accept-Encoding ~ "deflate") {
            # Next, try deflate if it is supported.
            set req.http.Accept-Encoding = "deflate";
        }
        else {
            # Unknown algorithm. Remove it and send unencoded.
            unset req.http.Accept-Encoding;
        }
    }

    ##------------------------------------------------------------------------------
    ## Always cache the following file types for all users.
    ##------------------------------------------------------------------------------
    if (req.url ~ "(?i)\.(jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc|webp|webm)(\?[a-z0-9]+)?$") {
        unset req.http.Cookie;
    }

    return (lookup);
}


##------------------------------------------------------------------------------
## Routine used to determine what to do when serving items from the webservers.
##------------------------------------------------------------------------------
sub vcl_fetch
{

    ##------------------------------------------------------------------------------
    ## Varnish determined the object was not cacheable
    ##------------------------------------------------------------------------------
    if (beresp.ttl <= 0s) {
        set beresp.http.X-Cacheable = "NO:Not Cacheable";

    ##------------------------------------------------------------------------------
    ## You don't wish to cache content for logged in users
    ##------------------------------------------------------------------------------
    } elsif (req.http.Cookie ~ "(UserID|_session)") {
        set beresp.http.X-Cacheable = "NO:Got Session";
        return(hit_for_pass);

    ##------------------------------------------------------------------------------
    # You are respecting the Cache-Control=private header from the backend
    ##------------------------------------------------------------------------------
    } elsif (beresp.http.Cache-Control ~ "private") {
        set beresp.http.X-Cacheable = "NO:Cache-Control=private";
        return(hit_for_pass);

    ##------------------------------------------------------------------------------
    # You are respecting the Cache-Control=no-cache header from the backend
    ##------------------------------------------------------------------------------
    } elsif (beresp.http.Cache-Control ~ "no-cache") {
        set beresp.http.X-Cacheable = "NO:Cache-Control=no-cache";
        return(hit_for_pass);
    ##------------------------------------------------------------------------------
    ## Don't allow static files to set cookies.
    ##------------------------------------------------------------------------------
    } elsif (req.url ~ "(?i)\.(jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc|webp|webm)(\?[a-z0-9]+)?$") {
        unset beresp.http.set-cookie;
        set beresp.grace = 6h;
        set beresp.ttl = 1h;
        set beresp.http.X-Cacheable = "YES";

    ##------------------------------------------------------------------------------
    # Varnish determined the object was cacheable
    ##------------------------------------------------------------------------------
    } else {
        set beresp.grace = 1h;
        set beresp.ttl = 5m;
        set beresp.http.X-Cacheable = "YES";
    }

}


##------------------------------------------------------------------------------
## Routine used to determine the cache key if storing/retrieving a cached page.
##------------------------------------------------------------------------------
sub vcl_hash {
    ##------------------------------------------------------------------------------
    # Build hash with HTTP METHOD + HTTP HOST + URL (with Query Params)
    ##------------------------------------------------------------------------------
    hash_data(req.request);
    hash_data(req.http.host);
    hash_data(req.url);

    return (hash);
}




#
# sub vcl_pipe {
#     # Note that only the first request to the backend will have
#     # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#     # have it set for all requests, make sure to have:
#     # set bereq.http.connection = "close";
#     # here.  It is not set by default as it might break some broken web
#     # applications, like IIS with NTLM authentication.
#     return (pipe);
# }
#
# sub vcl_pass {
#     return (pass);
# }
#
# sub vcl_hash {
#     hash_data(req.url);
#     if (req.http.host) {
#         hash_data(req.http.host);
#     } else {
#         hash_data(server.ip);
#     }
#     return (hash);
# }
#
# sub vcl_hit {
#     return (deliver);
# }
#
# sub vcl_miss {
#     return (fetch);
# }
#
# sub vcl_fetch {
#     if (beresp.ttl <= 0s ||
#         beresp.http.Set-Cookie ||
#         beresp.http.Vary == "*") {
# 		/*
# 		 * Mark as "Hit-For-Pass" for the next 2 minutes
# 		 */
# 		set beresp.ttl = 120 s;
# 		return (hit_for_pass);
#     }
#     return (deliver);
# }
#
# sub vcl_deliver {
#     return (deliver);
# }
#
# sub vcl_error {
#     set obj.http.Content-Type = "text/html; charset=utf-8";
#     set obj.http.Retry-After = "5";
#     synthetic {"
# <?xml version="1.0" encoding="utf-8"?>
# <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
#  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
# <html>
#   <head>
#     <title>"} + obj.status + " " + obj.response + {"</title>
#   </head>
#   <body>
#     <h1>Error "} + obj.status + " " + obj.response + {"</h1>
#     <p>"} + obj.response + {"</p>
#     <h3>Guru Meditation:</h3>
#     <p>XID: "} + req.xid + {"</p>
#     <hr>
#     <p>Varnish cache server</p>
#   </body>
# </html>
# "};
#     return (deliver);
# }
#
# sub vcl_init {
# 	return (ok);
# }
#
# sub vcl_fini {
# 	return (ok);
# }
