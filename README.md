# cert-generator-sh
Simple shell script certificate generator script for IEM instance installation

## Generate the certificates

Make it executable
```bash
chmod +x cert-generator.sh
```

Launch it passing your domain:
```bash
./cert-generator.sh testcerts.com
```

**testcerts.com-cascade.crt** and **rootCA.key** file will be generated can be imported to IEM installation:


## Import during IEM install

Example configuration for domain *testcerts.com*  

![Alt text](docs/testcerts.png?raw=true "IEM configuration")
