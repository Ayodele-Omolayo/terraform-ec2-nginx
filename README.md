Provider gives us complete access to his API, through AWS provider we have complete access to AWS and we can do whatever we like 

syntax for creating a resource in terraform: lets assume our provider to be AWS

resource "aws_vpc" "development_vpc"{

}

"aws_vpc" is the provider name underscore the service the provider wants to render and "development_vpc" is the name we decide to name this particular vpc we are creating