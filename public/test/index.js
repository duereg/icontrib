return {
            deps: [ '../tag/tag.js', 
                    '../login/login.js'
                  ],
            callback:   function(E, L) {
                            var body = E.div([ L.loginForm("/login_charity/","/check_charity/")
                                             ]);
                            return  {   title: "boxes are foxes.",
                                        main:   body
                                    };
                        }
        };