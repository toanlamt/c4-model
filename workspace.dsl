workspace {
    model {
        # People/Actors
        # <variable> = person <name> <description> <tag>
        customer = person "Personal Banking Customer" "A customer of the bank, with personal bank accounts." "Customer"

        # Software System
        # <variable> = softwareSystem <name> <description> <tag>
        iBankingSys = softwareSystem "Internet Banking System" "Allows customers to view information about their bank accounts, and make payments." "Target System" {
            # Level 2: Container
            # <variable> = softwareSystem <name> <description> <tag>
            # app = group "Application" {
                singlePageApp = container "Single-Page Application" "Provides all of the Internet banking functionality to customers via their web browser." "JavaScript and Angular" "Web Browser"
                mobileApp = container "Mobile App" "Provides a limited subset of the Internet banking functionality to customers via their mobile device." "Xamarin" "Mobile App"
                webApp = container "Web Application" "Delivers the static content and the Internet banking single page application." "Java and Spring MVC"
            # }
            apiApp = container "API Application" "Provides Internet banking functionality via a JSON/HTTPS API." "Java and Spring MVC" {
                # Level 3: Component
                signinController = component "Sign In Controller" "Allows users to sign in to the Internet Banking System." "Spring MVC Rest Controller"
                accountsSummaryController = component "Accounts Summary Controller" "Provides customers with a summary of their bank accounts." "Spring MVC Rest Controller"
                resetPasswordController = component "Reset Password Controller" "Allows users to reset their passwords with a single use URL." "Spring MVC Rest Controller"
                securityComponent = component "Security Component" "Provides functionality related to signing in, changing passwords, etc." "Spring Bean"
                mainframeBankingSystemFacade = component "Mainframe Banking System Facade" "A facade onto the mainframe banking system." "Spring Bean"
                emailComponent = component "E-mail Component" "Sends e-mails to users." "Spring Bean"
            }
            database = container "Database" "Stores user registration information, hashed authentication credentials, access logs, etc." "Oracle Database Schema" "Database"
        }
        
        # External Software Systems
        emailSys = softwareSystem "E-mail System" "The internal Microsoft Exchange e-mail system." "External System"
        mainframeSys = softwareSystem "Mainframe Banking System" "Stores all of the core banking information about customers, accounts, transactions, etc." "External System"

        # Relationship between People and Software Systems
        customer -> iBankingSys "Views account balances, and makes payments using"
        iBankingSys -> emailSys "Send email using" {
            tags "Async Request"
        }
        iBankingSys -> mainframeSys "Gets account information from, and makes payments using"
        emailSys -> customer "Sends emails to" {
            tags "Async Request"
        }

        # Relationship between Containers
        customer -> singlePageApp "Views account balances, and makes payments using"
        customer -> webApp "Visits bigbank.com/ib using" "HTTPS"
        customer -> mobileApp "Views account balances, and makes payments using"
        webApp -> singlePageApp "Delivers to the customer's web browser"
        mobileApp -> apiApp "Makes API calls to [JSON/HTTPS]"
        singlePageApp -> database "Reads from and writes to [JDBC]"
        singlePageApp ->  apiApp "Makes API calls to [JSON/HTTPS]"

        # Relationship between Containers and External System
        apiApp -> emailSys "Send email using" {
            tags "Async Request"
        }
        apiApp -> mainframeSys "Make API calls to [XML/HTTPS]"

        # Relationship between Components
        signinController -> securityComponent "Uses"
        accountsSummaryController -> mainframeBankingSystemFacade "Uses"
        resetPasswordController -> securityComponent "Uses"
        resetPasswordController -> emailComponent "Uses"
        securityComponent -> database "Reads from and writes to" "JDBC"
        mainframeBankingSystemFacade -> mainframeSys "Makes API calls to" "XML/HTTPS"
        emailComponent -> emailSys "Sends e-mail using" {
            tags "Async Request"
        }

        # Relationship between Components and Other Containers
        singlePageApp -> signinController "Makes API calls to" "JSON/HTTPS"
        singlePageApp -> accountsSummaryController "Makes API calls to" "JSON/HTTPS"
        singlePageApp -> resetPasswordController "Makes API calls to" "JSON/HTTPS"
        mobileApp -> signinController "Makes API calls to" "JSON/HTTPS"
        mobileApp -> accountsSummaryController "Makes API calls to" "JSON/HTTPS"
        mobileApp -> resetPasswordController "Makes API calls to" "JSON/HTTPS"

        # Deployment for Dev Env
        deploymentEnvironment "Development" {
            deploymentNode "Developer Laptop" "" "Microsoft Windows 10 or Apple macOS" {
                deploymentNode "Web Browser" "" "Chrome, Firefox, Safari, or Edge" {
                    containerInstance singlePageApp
                }
                deploymentNode "Docker Container - Web Server" "" "Docker" {
                    deploymentNode "Apache Tomcat" "" "Apache Tomcat 8.x" {
                        containerInstance webApp
                        containerInstance apiApp
                    }
                }
                deploymentNode "Docker Container - Database Server" "" "Docker" {
                    deploymentNode "Database Server" "" "Oracle 12c" {
                        containerInstance database
                    }
                }
            }
        }
    }

    views {
        # Level 1
        systemContext iBankingSys "SystemContext" {
            include *
            # default: tb,
            # support tb, bt, lr, rl
            autoLayout
        }
        # Level 2
        container iBankingSys "Containers" {
            include *
            autoLayout lr
        }
        component apiApp "Components" {
            include *
            autoLayout
        }
        # deployment <software-system> <environment> <key> <description>
        deployment iBankingSys "Development" "Dep-002-DEV" "Environment for Developer" {
            include *           
            autoLayout
        }
        dynamic apiApp "SignIn" "Summarises how the sign in feature works in the single-page application." {
            singlePageApp -> signinController "Submits credentials to"
            signinController -> securityComponent "Validates credentials using"
            securityComponent -> database "select * from users where username = ?"
            database -> securityComponent "Returns user data to"
            securityComponent -> signinController "Returns true if the hashed password matches"
            signinController -> singlePageApp "Sends back an authentication token to"
            autoLayout
        }

        styles {
            # element <tag> {}
            element "Customer" {
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