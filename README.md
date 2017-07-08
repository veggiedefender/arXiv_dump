# arXiv_dump
Download all arXiv papers

arXiv lets you [bulk download](https://arxiv.org/help/bulk_data_s3) papers from their s3 bucket. This is useful for doing your
`B I G D A T A` NLP tasks as a data science rockstar! This script will help you x10 your agile workflow by automating the 
boring stuff as you transfer big data from the cloud. What a paradigm shift! Code on, code ninja!

# How to use
To interact with s3, the script relies on [s3cmd](http://s3tools.org/s3cmd). Download it for your platform and run
`s3cmd --configure`. It'll ask for some keys which you can get from somewhere in AWS. Here's [a page that looks like
documentation for it](http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html). It'll ask for some other
stuff but I just pressed <kbd>enter</kbd> a bunch of times and it worked, so apparently the have some sensible defaults.

### Clone repository
`git clone https://github.com/veggiedefender/arXiv_dump`

### Run script
`./get_arxiv_data.sh`

It takes a really long time to run because you are now working with `B I G D A T A`. On my machine it takes about a minute to
download each tar, and 15-20 seconds to decompress them. There are 1519 archives in total at the time of writing.

### Output
You'll get a folder `out/` which contains folders numbered `0001`, `0002`, `0003`, etc. Inside each numbered folder are
folders for each paper, such as `astro-ph0001001`. It'll either have a bunch of files and a `.tex`, or a file with no
extension that is probably LaTeX formatted, but who really knows?

#### Note:
Each folder within `out/` is about ~140MB uncompressed and with non `*.tex` files removed. With 1519 archives, they should all
fit in about ~210GB.
