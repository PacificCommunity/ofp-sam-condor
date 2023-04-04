condor
======

The condor package provides tools to interact with Condor from R via SSH
connection. Files are first uploaded from user machine to submitter machine, and
the job is then submitted from the submitter machine to Condor. Functions are
provided to submit, list, and download Condor jobs from R. Condor is an
open-source high-throughput computing software framework for distributed
parallelization of computationally intensive tasks.

Installation
------------

The package can be installed from GitHub using the `install_github` command:

```R
library(remotes)
install_github("PacificCommunity/ofp-sam-condor")
```

Usage
-----

For a summary of the package:

```R
library(condor)
?condor
```

References
----------

* https://htcondor.org

Development
-----------

The condor package is developed openly on
[GitHub](https://github.com/PacificCommunity/ofp-sam-condor).

Feel free to open an
[issue](https://github.com/PacificCommunity/ofp-sam-condor/issues) there if you
encounter problems or have suggestions for future versions.
