# Semalogic

## Description
This git projekt is part of CAVAS+
It provides a REST/API service for coding and decoding rule sets using the semantic language [SemaLogic](https://semalogic.de).

## Installation
The SemaLogic development is tested in standard Windows 10/11 and Ubuntu 2404 Linux OS  environments. The generated executable should run without any major library requirement on any similar system.

## Usage
The REST/API server answers to JSON Post and Get packages defined by the OpenAPI version of the interface documentation.
The current version of the interface may, e.g. for a [locally running server](#running locally), be extracted by:
```
curl -X 'GET' \
  'http://localhost:28000/APIVersion' \
  -H 'accept: application/json'
```

You should see the response in your terminal as JSON content like:
```
{"runtime":"started: Monday, 24-Nov-25 05:31:03 UTC","version":"00.01.20 build 250903-1805","versiontext":"This version is the current version of openapi used to export SemaLogic to ASP in JSON format."}
```
The runtime shows the current start of the program (within docker container). The OpenAPI Version is printed next - the buildtime of the service is printed as second time stamp included in the version.

Please refer to current_build/openapi.yaml for more details.
You may want to open the openapi definition using the swagger-editor. There, you can interactively try the interface against the publicly available semalogic service. To test a locally installed version revert back the service adress to localhost.

### Running locally
Just start the SemaLogic executables depending on your OS environment from current_build/
The Rest API Server will start by default using Port 28000
You may change the port by using the -p option.
See ```Semalogic --help``` for more information on command line options.

### Running SemaLogic as Docker
A good start is to follow these steps:

1) Install your local docker environment
You may start by reading the [docker help](https://docs.docker.com/get-docker/) on this.

2) Build the docker container:
```
docker build -t $USER/semalogic .
```

3) Run the container:
```
docker run -d --name semalogic-service $USER/semalogic
```

4) Look up the network adress of the running docker:
```
docker inspect semalogic-service | grep IPAddress
```
will show the current IP of the running semalogic service.

5) Use the service:
Connect with [Swapper Inspector](https://inspector.swagger.io/builder)

## Support
Please contact the CAVAS+ project and/or Markus & Matthias at [SemaLogic](https://semalogic.de/Kontakt) for any help with running this REST/API service.

## Roadmap
The current version of the API is fully for ASP JSON related features.
Currently, only "ASP.json" answers are generated.

### Known Issues
- [x] Parsing processes sometimes crashs when wrong JSON format is used. - solved in v1.16
- [x] The OpenAPI version does not document fully the plain text capabilities of the service. - solved in v1.17
- [x] Check and advice terms are reflected in the ASP.json output. - solved in V1.17
- [ ] We export only the first matching term of a symbol to ASP.json output.
- [ ] Dynamic Groups do not yet contains all required symbols. Only symbols used as defintions elsewhere in the semantic tree are captured. Used symbols are ignored.
- [ ] Shadowing of nested definitions: Multiple Attrib definitions are not yet resolved correctly, if the assign multiple different values to e.g., the leafs.
- [ ] Nested Time terms are not yet correctly displayed by the SVG
  
## Authors and acknowledgment
Most of the SemaLogic go coding was done by Markus von der Heyde and Matthias Goebel.
We are thankful for the automatic code generate provided by golang and Swagger OpenAPI.
Thanks to Finn for the docker integration.

## License
This service is licensed to the University of Potsdam for research purpose in the context of the CAVAS+ project in reference to the SemaLogic pending patent.

## Project status
We are heading towards building a knowledge graph out of the SemaLogic semantic tree. This will help us to generate more appropriate SVGs and also validate complex cases better.

Several SemaLogic language features are not yet implemented in the SVG output:
- [ ] check, advice
- [ ] version-boxes, undecided type boxes
- [ ] filters
- [x] attributes when named as a symbol - done
- [ ] instances

Several SemaLogic language features are not yet implemented in the ASP-JSON output:
- [x] check, advice - done
- [ ] versions
- [ ] filters
- [x] instances, attributes - done

## Check out files
Pull repository by using 
```
git clone git@github.com:sltest-vdhit/SLTest.git
```

