# xxexpr.ss - an SXML-to-XML converter

The SSAX XML parsing- and processing-library provides robust,
high-quality XML reading tools for Scheme, but doesn’t include a
general purpose XML writer. Over the past couple of years, a few of my
projects have had a need to convert SXML-like data to an XML 1.0
external representation, and so I’ve written a portable SXML-to-XML
printing library. The library has been used with Chicken, MzScheme,
SISC, and Scheme48 to date.

The library is parameterized over a choice of double- or single-quotes
for attribute printing, and can, if required, be instructed to use
explicit close-tags when an empty-tag is encountered. It provides
procedures for producing a string representation of an XML fragment,
for printing an XML fragment directly to a port, and for
pretty-printing an XML fragment with indentation. For example,

    (pretty-print-xxexpr
     (let ((title "My Page"))
       (list
        '(*pi* xml (version "1.0"))
        `(html (head (title ,title))
               (body (h1 ,title)
                     (p "Hello, world!"))))))

produces the following output:

    <?xml version='1.0'?>
    <html>
        <head>
            <title>My Page</title>
        </head>
        <body>
            <h1>My Page</h1>
            <p>Hello, world!</p>
        </body>
    </html>

The code is available on github, at https://github.com/tonyg/xxexpr/.

## Licensing

Copyright (C) 2004,2005,2011 by Tony Garnock-Jones.

This is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the
Free Software Foundation; either version 2.1 of the License, or (at
your option) any later version.

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this software; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

Author: Tony Garnock-Jones <tonygarnockjones@gmail.com>
