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

Queries to the RSS consist both of queries of/within Top Level Domains
(TLDs) that do exist (e.g. .com, or .xxx) as well as queries that do
not exist (e.g. sensitive.internal, or sensitive.con).  These queries,
when an answer within a resolver's cache is not available, are sent to
the RSS and are delivered through networks in between the resolver and
the RSS.  To date the quantity of unanswerable queries is typically
double those of answerable queries.

To mitigate issues with potentially sensitive queries leaving a
resolver, various techniques are available for use that include:

- Aggressive Use of DNSSEC-Validated Cache {{RFC9077}} (often referred
  to as "Aggressive NSEC"): Once a single query between two valid TLDs
  has been leaked, validating resolvers can make use of the returned
  NSEC records to prevent future queries between the two bounding TLDs
  from leaking.  This greatly reduces, but not entirely eliminates,
  the leaked queries.  The rough worst case scenario is a leak of 1
  query per TLD in the root zone in the course of one TTL (2 days) or
  implementation limit (frequently 1 day).  Note that resolvers that
  prefer client NS records, which often have a lower TTL, may leak
  data more frequently than what the root zone TTL specifies.  Note
  that NSEC aggressive caching requires at least understanding NSEC
  records and ideally verifying them with DNSSEC.
  
- DNS Query Name Minimisation to Improve Privacy {{RFC9156}} (commonly
  referred to as QName Minimization): The original DNS protocol
  specifications {{RFC1035}} indicated that the entire query name
  being handled by a resolver should be sent to upstream authoritative
  servers, leaking all portions of the domain name.  {{RFC9156}}
  minimizes this leakage by specifying that resolvers should only
  query the authoritative source for the labels needed (at the slight
  expensive of potentially increased traffic).  This greatly improves
  privacy in the case where the sensitive information is in the labels
  before the TLD (e.g. sensitive.example).  However, this cannot
  entirely minimize the leakage of TLD names themselves, which may or
  may not be sensitive in nature (.xxx is commonly used as a common
  example).  Note, however, that like the Aggressive NSEC technique
  above, the queries leaked are typically cached for up to the TTL or
  other length.  Unlike NSEC Aggressive Caching, DNSSEC is not
  required to implement QName Minimization.

- LocalRoot {{RFC8806}}: because a LocalRoot implementation has all of
  the root zone data available to it, no queries to the root need to
  be sent at all.

## Latency

Latency to the RSS is generally thought not to be of critical
importance, as the majority of the resolvers should only rarely send
queries to the root for legitimate TLDs.  Queries containing
right-most labels that are not TLDs are subject to either Aggressive
NSEC caching time limitations, when deployed, or negative answer
caching as defined by the root zone's SOA field.

For negative answers, especially those from user inputs containing
typos, there is the possibility that in especially remote destinations
that the resolver a human is using is actually waiting for an answer
from back from the RSS.  In fact, this is one motivation listed in
{{RFC8806}} for implementing LocalRoot.

Techniques that support reducing latency to the root, often by having
the answers already available, include:

- Aggressive Use of DNSSEC-Validated Cache {{RFC9077}} potentially
  prevents needing to send queries for unknown negative answers, as
  discussed above.
  
- LocalRoot {{RFC8806}}: As above, a LocalRoot implementation already
  has the information in the root zone and thus can answer immediately
  and without sending any queries to the RSS.

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
