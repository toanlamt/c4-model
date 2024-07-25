workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        publicUser = person "Public User" "An anonymous user of the bookstore" "User"
        authorizedUser = person "Authorized User" "A registered user of the bookstore, with personal account" "User"
        internalUser = person "Internal User" "An internal user of the bookstore system, with internal account" "User"

        # Software Systems
        # <variable> = softwareSystem <name> <description> <tag>
        bookstoreSystem = softwareSystem "Bookstore System" "Allows users to view about book, and administrate the book details" "Target System" {
            # Level 2: Containers
            # <variable> = container <name> <description> <technology> <tag>
            frontStoreApp = container "Front-store Application" "Provides all bookstore functionalities to public and authorized users" "JavaScript & ReactJS"
            backOfficeApp = container "Back-office Application" "Provides all bookstore administration functionalities to internal users" "JavaScript & ReactJS"
            searchWebApi = container "Search Web API" "Allows only authorized users to searchs books information via HTTPs API" "Go"
            searchDatabase = container "Search Database" "Stores the book searchable data" "ElasticSearch" "Database"
            publicWebApi = container "Public Web API" "Allows public users to search books information using HTTPs" "Go"
            # Level 3: Components
            adminWebApi = container "Admin Web API" "Allow ONLY internal users to manage books and purchases information using HTTPs." "Go" {
                bookService = component "Book Service" "Allows administrating book details" "Go"
                authorizerService  = component "Authorizer" "Authorize the internal users" "Go"
                bookEventPublisher = component "Book Events Publisher" "Publishes books-related events" "Go"
            }
            bookstoreDatabase = container "Bookstore Database" "Stores book data" "PostgreSQL" "Database"
            bookEventSystem = container "Book Event System" "Handle book update events" "Apache Kafka 3.0"
            bookEventConsumer = container "Book Event Consumer" "Handle book update events" "Go"
            publisherRecurrentUpdater = container "Publisher Recurrent Updater" "Listens to external events from Publisher System and updates data using Admin Web API" "Go"
        }
        
        # External Software Systems
        identifyProviderSystem = softwareSystem "Identify Provider System" "The external service for authorization purposes." "External System"
        publisherSystem = softwareSystem "Publisher System" "The external service for collects the published book details" "External System"
        shippingService = softwareSystem "Shipping Service" "The 3rd party service to handle the book delivery" "External System"
        
        # Relationship between People and Software Systems
        # <variable> -> <variable> <description> <protocol>
        publicUser -> bookstoreSystem "View book information"
        authorizedUser -> bookstoreSystem "Search book with more details and their details"
        internalUser -> bookstoreSystem "Administrate books"
        publicUser -> frontStoreApp "Uses all bookstore functionalities"
        authorizedUser -> frontStoreApp "Uses all bookstore functionalities"
        internalUser -> backOfficeApp "Uses all bookstore administration functionalities"
        authorizedUser -> searchWebApi "Search book with more detail" "JSON/HTTPS"
        publicUser -> publicWebApi "Search book information" "JSON/HTTPS"
        internalUser -> adminWebApi "Manage books and purchases information" "JSON/HTTPS"
        bookstoreSystem -> identifyProviderSystem "Register new user, and authorize user access"
        publisherSystem -> bookstoreSystem "Collects published book details" {
            tags "Async Request"
        }
        bookstoreSystem -> shippingService "Handle book delivery"

        # Relationship between Containers
        frontStoreApp -> publicWebApi "Place order"
        frontStoreApp -> searchWebApi "Search book"
        backOfficeApp -> adminWebApi "Administrate books and purchases"
        searchWebApi -> identifyProviderSystem "Authorize user" "JSON/HTTPS"
        searchWebApi -> searchDatabase "Searches book information"
        publicWebApi -> bookstoreDatabase "Read/Write data" "ODBC"
        adminWebApi -> identifyProviderSystem "Authorize user" "JSON/HTTPS"
        adminWebApi -> bookstoreDatabase "Read/Write data" "ODBC"
        adminWebApi -> bookEventSystem "Publish book events" {
            tags "Async Request"
        }
        bookEventSystem -> bookEventConsumer "Forward event to"
        bookEventConsumer -> searchDatabase "Write data" "ODBC"
        publisherRecurrentUpdater -> adminWebApi "Update data"

        # Relationship between Containers and External System
        publisherSystem -> publisherRecurrentUpdater "Listen to external events"

        # Relationship between Components
        internalUser -> bookService "Administrate book details" "JSON/HTTPS"
        bookService -> authorizerService "Uses"
        bookService -> bookEventPublisher "Uses"

        # Relationship between Components and Other Containers
        authorizerService -> identifyProviderSystem "Authorize user permissions" "JSON/HTTPS"
        bookService -> bookstoreDatabase "Read/Write data" "ODBC"
        bookEventPublisher -> bookEventSystem "Publish book-related events"
    }

    views {
        # Level 1
        systemContext bookstoreSystem "SystemContext" {
            include *
            autoLayout bt
        }
        # Level 2
        container bookstoreSystem "Containers" {
            include *
            autoLayout lr
        }
        # Level 3
        component adminWebApi "Components" {
            include *
            autoLayout lr
        }


        styles {
            # element <tag> {}
            element "User" {
                background #08427B
                color #ffffff
                fontSize 22
                shape Person
            }
            element "External System" {
                background #999999
                color #ffffff
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Async Request" {
                dashed true
            }
            element "Database" {
                shape Cylinder
            }
        }

        theme default
    }

}