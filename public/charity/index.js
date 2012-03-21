var deps = [
    '/tag/tag.js', 
    '/tag/layout1.js', 
    '/ui/core.js', 
    '/ui/nav.js',
    params.id + '.json'
];

function onReady(Tag, Layout, Core, Nav, User) {
    
    function charity(as) {
        as = as || {};
        var user = as.user;
	var box = Core.box([
            Layout.spoon([
	        Tag.div({style: {height: '30px'}}, [Core.h2(user.organizationName)]),
                Layout.pillow(20),
                Layout.hug([
                    Tag.img({style: {width: '175px', height: '175px', borderRadius: '5px'}, src: user.imageUrl, alt: user.organizationName}),
                    Layout.pillow(30),
                    Layout.spoon([
                        Tag.p({style: {height: '100px', width: '600px'}}, user.mission), 
                        Layout.pillow(20),
                        Core.button({href: '/me/?donateTo=' + user.id, text: 'Donate!', loud: true})
                    ])
                ])
            ])
        ]);

        return Layout.spoon([
           box,
           Layout.pillow(30)
        ]);
    }

    var main = Nav.frame([charity({user: User})]);

    define(main);

}

require(deps, onReady);

