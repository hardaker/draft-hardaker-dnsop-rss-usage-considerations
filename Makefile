# Makefile for IETF Draft

# Warren sucks at make!

# Variables
MD_FILE := draft-hardaker-dnsop-rss-usage-considerations.md
XML_FILE := $(MD_FILE:.md=.xml)
TXT_FILE := $(MD_FILE:.md=.txt)
MAKEFILE := Makefile

# Default target
all: $(TXT_FILE)

# Convert Markdown to XML
$(XML_FILE): $(MD_FILE)
	@kramdown-rfc $(MD_FILE) > $(XML_FILE) || { echo "Markdown to XML conversion failed."; exit 1; }

# Convert XML to TXT
$(TXT_FILE): $(XML_FILE)
	@xml2rfc $(XML_FILE) > $(TXT_FILE) || { echo "XML to TXT conversion failed."; exit 1; }

# Clean up generated files
clean:
	rm -f $(XML_FILE) $(TXT_FILE)

.PHONY: all clean