exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js",

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
        order: {
        before: [
      //      "web/static/vendor/jquery/jquery.min.js",
       //     "web/static/vendor/bootstrap/js/bootstrap.bundle.min.js",
        //    "web/static/vendor/js/sb-admin.min.js"
        ]
        }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        before: [
            "web/static/css/phoenix.css"
        ],
        after: ["web/static/css/app.scss"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static",
        "scss"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
      copycat: {
    "fonts": ["node_modules/font-awesome/fonts"]
  },
  sass: {
    options: {
      includePaths: ["node_modules/bootstrap/scss", "node_modules/font-awesome/scss"], // for sass-brunch to @import files
      precision: 8 // minimum precision required by bootstrap
    }
  }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true,
globals: {
      // Bootstrap JavaScript requires both '$', 'jQuery'
      $: 'jquery',
      jQuery: 'jquery',
      bootstrap: 'bootstrap' // require Bootstrap JavaScript globally too
    }
  }
};
