---
title: "DNS Root Server System Usage Considerations"
abbrev: "DNS RSS Usage Considerations"
category: info

docname: draft-hardaker-dnsop-rss-usage-considerations
submissiontype: IETF
consensus: true
v: 3
area: "Operations and Management"
workgroup: "Domain Name System Operations"
keyword:
 - DNS
 - DNSSEC
 - zone cut
 - delegation
 - referral
updates: RFC8806
venue:
  group: "Domain Name System Operations"
  type: "Working Group"
  mail: "dnsop@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/dnsop/"
  github: "https://github.com/hardaker/draft-hardaker-dnsop-root-zone-publication-points"

author:
  -
    fullname: Wes Hardaker
    organization: Google, Inc.
    email: ietf@hardakers.net
  -
    fullname: Warren Kumari
    organization: Google, Inc.
    email: warren@kumari.net
  -
    ins: J. Reid
    name: Jim Reid
    org: RTFM llp
    street: St Andrews House
    city: 382 Hillington Road, Glasgow Scotland
    code: G51 4BL
    country: UK
    email: jim@rfc1035.com
  -
    ins: G. Huston
    fullname: Geoff Huston
    organization: APNIC
    email: gih@apnic.net
    street: 6 Cordelia St
    city: South Brisbane
    code: QLD 4101
    country: Australia

normative:
  BCP237:
  RFC4033:  # DNSSEC
  RFC8976:  # ZONEMD

informative:
  RFC2826:  # unique root 
  RFC5936:  # DNS Zone Transfer
  RFC7766:  # DNS Transport over TCP
  RFC9110:  # HTTP Semantics and Methods

  draft-hardaker-dnsop-dns-xfr-scheme:
    title: The DNS XFR URI Schemes
    target: https://datatracker.ietf.org/doc/draft-hardaker-dnsop-dns-xfr-scheme/
  draft-hardaker-dnsop-root-zone-publication-list-guidelines:
    title: Guidelines for IANA DNS Root Zone Publication List Providers
    target: https://datatracker.ietf.org/doc/draft-hardaker-dnsop-root-zone-publication-list-guidelines
  draft-wkumari-dnsop-localroot-bcp:
    title: Populating resolvers with the root zone
    target: https://datatracker.ietf.org/doc/draft-wkumari-dnsop-localroot-bcp/
  NOROOTS:
    title: On Eliminating Root Nameservers from the DNS
    target: https://www.icir.org/mallman/pubs/All19b/All19b.pdf

--- abstract

This document discusses the positive and negative aspects of the
centralized nature of the DNS Root Server System infrastructure (RSS).  Note
that this is separate from the centralization of the contents of the
DNS RSS, which is needed for globally unique identifier system and is
also outside the scope of this document.

--- middle

# Introduction

This document discusses the positive and negative aspects of the
centralized nature of the DNS Root Server System infrastructure (RSS).
Note that this is separate from the centralization of the contents of
the DNS RSS, which is needed for globally unique identifier system
{{RFC2826}} and is also outside the scope of this document.

# Centralized vs Decentralized RSS Characteristics

## Privacy

## Latency

## Disconnected operations

At times a region may become disconnected from the larger internet due
to operational failures from many causes (network outages, intentional
disruptions, natural catastrophes, etc).  In this situation, because the RSS
serves as the pinnacle of the DNS, any resolver needing information
about TLDs would be effectively unable to respond to related queries
without implementation a solution that allows it to operate in a
disconnected state.

Solutions available for continuing to operate even when disconnected
from the RSS:

- Serve Stale: {{RFC8767}} -- defines how a resolver can continue to
  use and serve previously obtained records who's TTLs have otherwise
  expired.  This solution benefits both data from the RSS and from
  other authoritative servers, however it requires that the needed
  data exists in the cache in the first place.

- LocalRoot: {{RFC8806}} -- provides a local copy of the entire RSS to
  be used.  Implementations that do this may have used a pre-caching
  technique, in which case it would likely be useful similarly to the
  Serve Stale results.  Other implementations may have the entire copy
  remain in active use, regardless of when it was obtained, such as
  through the use of a parallel authoritative server or via a special
  cache marking or similar, in which case the entire RSS data would
  remain viable a significantly longer period of time.

# Operational Considerations

TBD

# Security Considerations

TBD

# IANA Considerations

TBD: describe the request for IANA to support a list of root server
publication points at TBD-URL.

--- back


# Acknowledgments
{:numbered="false"}

TBD
