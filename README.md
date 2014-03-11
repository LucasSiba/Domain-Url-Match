Domain-Url-Match
================

Tool for finding all URL's that match a given list of Domains

Notes
- This tool uses Perl and does all sorting/matching in memory, so you can expect the process to be about 5 times larger then the size of the input files.
- Empty lines and lines starting with '#' are ignored
- A URL with a domain of 'foo.bar.com' will be matched by a domain of 'bar.com' (you can easily change this feature if you don't want it)
