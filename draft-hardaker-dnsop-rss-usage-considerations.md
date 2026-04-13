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
 - root zone
venue:
  group: "Domain Name System Operations"
  type: "Working Group"
  mail: "dnsop@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/dnsop/"
  github: "https://github.com/hardaker/draft-hardaker-dnsop-rss-usage-considerations"

author:
  -
    fullname: Wes Hardaker
    organization: Google, Inc.
    email: ietf@hardakers.net

normative:

informative:

  draft-hardaker-dnsop-dns-xfr-scheme:
    title: The DNS XFR URI Schemes
    target: https://datatracker.ietf.org/doc/draft-hardaker-dnsop-dns-xfr-scheme/
  draft-hardaker-dnsop-root-zone-publication-list-guidelines:
    title: Guidelines for IANA DNS Root Zone Publication List Providers
    target: https://datatracker.ietf.org/doc/draft-hardaker-dnsop-root-zone-publication-list-guidelines
  LOCALROOT:
    title: Populating resolvers with the root zone
    target: https://datatracker.ietf.org/doc/draft-wkumari-dnsop-localroot-bcp/
  NOROOTS:
    title: On Eliminating Root Nameservers from the DNS
    target: https://www.icir.org/mallman/pubs/All19b/All19b.pdf
  ROOTPRIVACY:
    title: Analyzing and mitigating privacy with the DNS root service
    target: http://www.isi.edu/~hardaker/papers/2018-02-ndss-analyzing-root-privacy.pdf

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

# Document Conventions

This document discusses various technical considerations when
resolvers communicate with the DNS Root Server System (RSS) and
techniques available for resolvers to improve their communication
efficiency and security with the RSS.  For concerns addressed below,
the various solution techniques are categorized using the following
labels:

* minimal: medium the technique addresses the problem with only a
  small amount of improvement.
* medium: the technique addresses the problem with a medium amount of
  improvement.
* significant: the technique addresses the problem that significantly
  reduces the problem space, even though it does not entirely
  alleviate it.
* entirely: the technique completely mitigates the problem.

# Techniques Affecting Communication with the RSS {#techniques}

The following subsections describe the techniques discussed in this
document.  In particular, for each of the communication with the RSS
subtopics in {{analysis}}, these techniques will be referred to and
compared for their effectiveness in each scenario.

## QName Minimization

The DNS Query Name Minimisation to Improve Privacy {{RFC9156}}
specification describes how recursive resolvers can minimize the
privacy leakage by describing how the resolver "no longer always sends
the full original QNAME and original QTYPE to the upstream name
server."

## Aggressive NSEC

The Aggressive Use of DNSSEC-Validated Cache {{RFC8198}} {{RFC9077}}
specification describes how validating recursive resolvers can reduce
the queries sent to authoritative servers by allowing
"DNSSEC-validating resolvers to generate negative answers within a
range and positive answers from wildcards."

## DNS over TLS / DTLS /DoH

The specifications for DNS over Transport Layer Security (TLS)
{{RFC7858}} and DNS over Datagram Transport Layer Security (DTLS)
{{RFC8094}} (along with supplemental information {{RFC8310}}) are
designed to minimize the visibility of the traffic from clients to the
recursive resolvers (collectively referred to as "DNS over (D)TLS").
Similarly, DNS Queries over HTTPS (DoH) {{RFC8484}} and Oblivious DNS
over HTTPS {{RFC9230}} enable DNS over HTTP transports that also
protect the queries in transit to recursive resolvers.

The Unilateral Opportunistic Deployment of Encrypted
Recursive-to-Authoritative DNS {{RFC9539}} specification defines how
recursive resolvers can communicate with authoritative servers that
support encrypted TLS sessions. At this time the specification is
published under an EXPERIMENTAL status.

## LocalRoot

The various LocalRoot specifications and implementations provide
recursive resolvers with the ability to keep and use a copy of the
root zone locally rather than sending queries directly to the root
zone.  The concepts have been documented in various IETF documents
({{RFC7706}}, {{RFC8806}}, {{LOCALROOT}}), academic papers
({{NOROOTS}}, {{ROOTPRIVACY}}) and implementations {{BINDMIRROR}},
{{KNOTMODULE}}, {{UNBOUNDAUTHZONE}}, {{LOCALROOTISI}}.  The earliest
specifications and implementations made exclusive use of AXFR for
transferring root zone data but later specifications and
implementations have also allowed for the use of transferring the root
zone using the HTTP protocol.

# Centralized vs Decentralized RSS Characteristics {#analysis}

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

- Aggressive NSEC: Once a single query between two valid TLDs has been
  leaked, validating resolvers can make use of the returned NSEC
  records to prevent future queries between the two bounding TLDs from
  leaking.  This greatly reduces, but not entirely eliminates, the
  leaked queries.  The rough worst case scenario is a leak of 1 query
  per TLD in the root zone in the course of one TTL (2 days) or
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
  
- Specification for DNS over Transport Layer Security (TLS)
  {{RFC7858}} and DNS over Datagram Transport Layer Security (DTLS)
  {{RFC8094}} (along with supplemental information {{RFC8310}}) are
  designed to minimize the visibility of the traffic to the recursive
  resolvers (collectively referred to as "DNS over (D)TLS").  
  DNS Queries over HTTPS (DoH) {{RFC8484}} and Oblivious DNS over
  HTTPS {{RFC9230}} enable DNS over HTTP transports that also protect
  the queries in transit to recursive resolvers.  However, these
  protocol definitions do not support DNS queries from the recursive
  resolver to authoritative servers, such as the RSS.
  
  The Unilateral Opportunistic Deployment of Encrypted
  Recursive-to-Authoritative DNS {{RFC9539}} specification does define
  recursive to authoritative authenticated and encrypted TLS sessions
  but is an EXPERIMENTAL status document at this time.  At the time of
  this writing, only 2 of the 13 root server identifiers support DNS
  over TLS transactions.  With DNS over (D)TLS in place, the query
  name leakage to the intermediate networks is removed leaving only
  queries to only leak to the RSS itself.

- LocalRoot {{LOCALROOT}}: because a LocalRoot implementation has all of
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
{{LOCALROOT}} for implementing LocalRoot.

Techniques that support reducing latency to the root, often by having
the answers already available, include:

- Aggressive Use of DNSSEC-Validated Cache {{RFC9077}} potentially
  prevents needing to send queries for unknown negative answers, as
  discussed above.
  
- LocalRoot {{LOCALROOT}}: As above, a LocalRoot implementation already
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

- LocalRoot: {{LOCALROOT}} -- provides a local copy of the entire RSS to
  be used.  Implementations that do this may have used a pre-caching
  technique, in which case it would likely be useful similarly to the
  Serve Stale results.  Other implementations may have the entire copy
  remain in active use, regardless of when it was obtained, such as
  through the use of a parallel authoritative server or via a special
  cache marking or similar, in which case the entire RSS data would
  remain viable a significantly longer period of time.

## Glue Protection {#glue}

Although DNSSEC protects the NS records within the root zone data, the
A and AAAA glue records are not signed.  Thus they could be modified
by machine-in-the-middle attacks, cache injection techniques, etc to
either block traffic by changing the addresses to servers that don't
respond, or to alternate addresses that do respond.  For addresses
that do respond, they will unable to alter root or TLD related data
without being detected by validating resolvers, however they could be
used as a form of surveillance by continuing to proxy legitimate
requests while recording the transactions.  Note that glue records
from the root zone are typically cached for a lengthy period of time,
depending on the parent and child TTLs, which is a benefit for
resolvers that receive the correct records but a detriment for those
that receive modified records.

Solutions to this problem space include:

- DNSSEC {{RFC9364}} prevents malicious modification of critical data,
  thus preventing false insertion of data that is not signed.
  However, it does not prevent glue record modification.

- LocalRoot implementations {{LOCALROOT}} download and verify the entire
  contents of the root zone, including glue records, and thus
  eliminates this threat entirely.

## Bit Flipping

Bit flipping is defined as accidental modifications to bits most
frequently in memory or during transmission where a single bit may
flip from 0 to 1, or vice versa.  These occur with some level of
randomness and though they are rare, they can be measured in network
traffic arriving at very popular servers of all types.  The
root-servers.net zone is, unsurprisingly, a very popular domain
because it bootstaps all DNS resolutions on the Internet.  Researchers
have shown that by registering alternate domain names with single or
double bit flips in the domain name to DNS names allows these servers
to receive some non-zero number of requests to them for the legitimate
domain.  This could cause problems similar to as the above discussed
glue record modifications ({{glue}}).

Cyptographic techniques properly identify and reject data with
modifications of any kind, including bit flipping techniques.  Note
that in this section we only discuss bitflips that are received by the
resolver, or for answers coming back to queries from the RSS as an
authoritative server being queried.  Bitflips that occur in packets
leaving the resolver toward the client submitting the original request
are out of scope and not covered in this document as the resolver has
no control over them.

Solutions to this problem space include:

- DNSSEC {{RFC9364}} prevents malicious modification of critical data,
  thus preventing data bit flips of DNSSEC signed data.
  However, it does not prevent glue record modification as glue
  records, as discussed above, are not protected by DNSSEC.

- LocalRoot implementations {{LOCALROOT}} download and verify the entire
  contents of the root zone, including glue records, and thus
  eliminates this threat entirely for incoming queries.

# Operational Considerations

TBD

# Security Considerations

This document discusses a large number of security related cases in
{{analysis}} and proposes mitigation strategies, their effectiveness,
and associated trade-offs.

# IANA Considerations

TBD: describe the request for IANA to support a list of root server
publication points at TBD-URL.

--- back


# Acknowledgments
{:numbered="false"}

TBD
