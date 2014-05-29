<a name="v1.4.0"></a>
# v1.4.0 (2014-05-29)

## :sparkles: Features

- Adds luma function to color-model ([f7fa32de](https://github.com/abe33/pigments/commit/f7fa32dee41aadf91aef99d2f224497d4088ba41))

<a name="v1.3.0"></a>
# v1.3.0 (2014-05-29)

## :racehorse: Performances

- Totally revert to previous operation handling ([f90d529](https://github.com/abe33/pigments/commit/f90d52924257309155d89369644468651c4024a7))
  <br>The « smart » version was too expensive, and was using too much
recursion, a simple file with many operations was causing racing
conditions that was causing the search to never end. It also leads the
search process to climb to several Go in RAM.

<a name="v1.2.0"></a>
# v1.2.0 (2014-05-29)

## :sparkles: Features

- Implements a fully asynchrone operation search ([41e9e472](https://github.com/abe33/pigments/commit/41e9e472557d187b9f8c253aca0821e7150071f2))


<a name="v1.1.1"></a>
# v1.1.1 (2014-05-29)

## :bug: Bug Fixes

- Fixes parsing order that was jumping too far in text ([2bd5874d](https://github.com/abe33/pigments/commit/2bd5874d56124b7e3481191d8417924ed56d2493))


<a name="v1.1.0"></a>
# v1.1.0 (2014-05-29)

## :sparkles: Features

- Adds public methods to remove expressions/operations ([dfff95cb](https://github.com/abe33/pigments/commit/dfff95cb639001640d0cd68b79d88db273de6fa2))
- Adds a name to identify expressions and operations ([e8e42ebb](https://github.com/abe33/pigments/commit/e8e42ebb4832db62837e4e35d36600d82d1af8c5))
