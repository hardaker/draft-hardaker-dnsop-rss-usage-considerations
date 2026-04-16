---
title: "DNS Root Server System Usage Considerations"
abbrev: "DNS RSS Usage Considerations"
category: info

docname: draft-hardaker-dnsop-rss-usage-considerations-latest
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

  RFC1035:
  RFC2826:
  RFC7706:
  RFC7858:
  RFC8094:
  RFC8198:
  RFC8310:
  RFC8484:
  RFC8767:
  RFC8806:
  RFC9077:
  RFC9156:
  RFC9230:
  RFC9364:
  RFC9539:
  KNOTMODULE:
    title: know module to support LocalRoot
    target: https://knot-resolver.readthedocs.io/en/latest/lib.html
  BINDMIRROR:
    title: bind instructions for mirroring the root zone
    target: https://bind9.readthedocs.io/en/v9.18.41/reference.html
  draft-hardaker-dnsop-dns-xfr-scheme:
    title: The DNS XFR URI Schemes
    target: https://datatracker.ietf.org/doc/draft-hardaker-dnsop-dns-xfr-scheme/
  draft-hardaker-dnsop-root-zone-publication-list-guidelines:
    title: Guidelines for IANA DNS Root Zone Publication List Providers
    target: https://datatracker.ietf.org/doc/draft-hardaker-dnsop-root-zone-publication-list-guidelines
  LOCALROOT:
    title: Populating resolvers with the root zone
    target: https://datatracker.ietf.org/doc/draft-wkumari-dnsop-localroot-bcp/
  LOCALROOTISI:
    title: The LocalRoot project to help operators use LocalRoot
    target: https://localroot.isi.edu/
  UNBOUNDAUTHZONE:
    title: Unbound documentation for supporting LocalRoot
    target: https://unbound.docs.nlnetlabs.nl/en/latest/manpages/unbound.conf.html
  NOROOTS:
    title: On Eliminating Root Nameservers from the DNS
    target: https://www.icir.org/mallman/pubs/All19b/All19b.pdf
  ROOTPRIVACY:
    title: Analyzing and mitigating privacy with the DNS root service
    target: http://www.isi.edu/~hardaker/papers/2018-02-ndss-analyzing-root-privacy.pdf

--- abstract

This document discusses the various technologies that have been
developed to enhance communication with the DNS generally but in the
specific view point of communicating with the the DNS Root Server
System (RSS).  We consider each of the recently developed protocols
and how they change and improve communication with the RSS.

--- middle

# Introduction

This document discusses the various technologies that have been
developed to enhance communication with the DNS generally but in the
specific view point of communicating with the the DNS Root Server
System (RSS).  We consider each of the recently developed protocols
and how they change and improve communication with the RSS.

Note that the need itself for a centralized source of a unique
internet naming system is outside the scope of this document, but is
well covered in {{RFC2826}}.

This document begins with a brief description and reference to the
various communication enhancements in {{techniques}} and follow that
with an analysis of how they might improve upon communication with the
RSS in {{analysis}}.

## Document Conventions

For each of the potential changes to RSS communication in
{{analysis}}, we categorize the various solution by how much they
improve or mitigate the concerns using the following keywords:

- Minimal: the technique addresses the problem with only a
  minimal amount of improvement.

- Moderate: the technique addresses the problem with a moderate amount
  of improvement.

- Significant: the technique addresses the problem that offers
  significant improvement for communicating with the RSS, even though
  it does not entirely address the problem space.

- Complete: the technique completely enhances communication with the
  RSS or completely mitigates the defined concern.

# Techniques Affecting Communication with the RSS {#techniques}

The following subsections describe the techniques discussed in this
document.  In particular, for each of the communication with the RSS
subtopics in {{analysis}}, these techniques will be referred to and
compared for their effectiveness in each scenario.

## QName Minimization

The original DNS protocol
specifications {{RFC1035}} indicated that the entire query name
being handled by a resolver should be sent to upstream authoritative
servers, leaking all portions of the domain name.
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

## Serve Stale

The "Serving Stale Data to Improve DNS Resiliency" {{RFC8767}}
specifications defines how a resolver can continue to use and serve
previously obtained records who's TTLs have otherwise expired.

## DNSSEC

DNSSEC {{RFC9364}} prevents malicious modification of responses from
the root and other signed zones to ensure that validating resolvers or
clients have the ability to determine its authenticity and timeliness.

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

The subsections below discuss the effects of the techniques listed in
{{techniques}} when recursive resolvers communicate with the Root
Server System.

## Privacy

Queries to the RSS consist of queries within Top Level Domains (TLDs)
that do exist (e.g. .com, or .xxx) as well as queries that do not
exist (e.g. sensitive.internal, or sensitive.con (sic)).  To date the
quantity of unanswerable queries is typically double those of
answerable queries.

When an answer is not within a resolver's cache the query must be sent
to the RSS.  The queries and responses to them are are delivered
through networks in between the resolver and the RSS.  Thus the
resulting set of entities that may see the contents of a query include
the up to 12 RSOs that serve the RSS and to which queries are sent and
the networks in between the client resolver and the RSO.

The privacy sensitivity of queries sent to the RSS can vary widely
ranging from unlikely sensitive (such as a query for just ".com"
without any left hand labels) or more critical queries that leak
potentially personal or system sensitive information that was not
intended to leak beyond an internal network boundary (such as TBD).
These accidental leaks can stem from typos, leaked web browser keyword
searches, misconfigured systems and software, or simply because it
needed to be resolved and no privacy protecting techniques listed
below were deployed.

Note that beyond the analysis of a single record being observed that a
larger or temporal analysis may reveal additional information and/or
behavioral patterns ({{ROOTPRIVACY}}).  For example, the collection of
unique CCTLDs observed being queried during the course of a 24 hour
period may reveal the political bias in a resolver's clients.

To mitigate issues with potentially sensitive queries leaving a
resolver, various techniques are available for use that include:

- Aggressive NSEC: Significant

  Once a single query between two valid TLDs has been
  leaked, validating resolvers can make use of the returned NSEC
  records to prevent future queries between the two bounding TLDs from
  leaking.  This greatly reduces, but not entirely eliminates, the
  leaked queries.  The rough worst case scenario with a long lived
  cache is a leak of 1 query per TLD in the root zone in the course of
  one TTL (2 days, or other implementation upper limit which can
  commonly be 1 day).  Note that resolvers which prefer client NS
  records, which often have a lower TTL, may leak data more frequently
  than what the root zone TTL specifies.  Note that NSEC aggressive
  caching requires resolvers to at least understand NSEC records and
  hopefully verify them with DNSSEC.

- QName Minimisation: Significant

  QName Minimisation greatly improves privacy in the case where the
  sensitive information is in the labels before the TLD
  (e.g. sensitive.example).  However, this cannot entirely minimize
  the leakage of TLD names themselves, which may or may not be
  sensitive in nature (.xxx is commonly used as a common example).
  Note that like the Aggressive NSEC technique above, the queries
  leaked are typically cached for up to the TTL or other length.
  Unlike NSEC Aggressive Caching though, DNSSEC is not required to
  implement QName Minimization.

- DNS over TLS / DoT / DoH: Moderate

  At the time of this writing, only 2 of the 13 root server
  identifiers support DNS over TLS transactions.  With DNS over (D)TLS
  in place at a resolver and at least some identifiers, the query name
  leakage to the intermediate networks in a path is removed, leaving
  only the Root Server Operators receiving queries to the root zone.

- LocalRoot: Complete

  Because a LocalRoot implementation has all of the root zone data
  available to it, no queries to the root need to be sent at all.
  Furthermore, because the data is received and verified before use
  locally, and because no queries are sent, there is only two
  remaining source of trust for the information used: IANA itself and
  the RZM who are responsible for creating the root zone, although
  even they have no visibility into how resolvers make use of the data.

## Latency

Latency to the RSS is generally thought not to be of critical
importance with traffic sent to the RSS, as the majority of the
resolvers should only rarely send queries to the root for legitimate
TLDs.  However, because negative answers are more frequent and may be
from end-user typos or similar that latency to the RSS matters at
least a little as a user may be directly waiting for a response before
realizing their error.  In fact, this is one motivation listed in
{{RFC8806}} for implementing LocalRoot.

Techniques that support reducing latency to the root, often by having
the answers already available, include:

- Aggressive NSEC: Significant

  With Agressive NSEC deployed, queries containing right-most labels
  (TLD labels) that are not in the root and are covered by an NSEC
  record that is in the (validating) resolver's cache are not sent and
  thus answerable immediately.  The result is similar to privacy
  analysis showing that Aggressive NSEC provides significant latency
  reduction to the root zone.

- LocalRoot: Complete

  As above, a LocalRoot implementation already has the information in
  the root zone and thus can answer immediately and without sending
  any queries to the RSS.

- Serve Stale: N/A

  Note that though Serve Stale may have an answer in the cache that is
  usable, it does not help with latency since the answer should not be
  used until an attempt to query the RSS has already been made.

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

- Serve Stale: Significant

  Serve Stale benefits both data from the RSS and from other
  authoritative servers, however it requires that the needed data
  exists in the cache in the first place.  Because it is likely that a
  resolver may have information about a TLD in its cache it could
  significantly help in a disconnected state, although it will not
  help in cases where cache state for a TLD has never been filled or
  has been expunged.

- LocalRoot: Significant or Complete

  LocalRoot implementations that fill their cache with records from
  the root zone should be similarly protected as Serve Stale, as cache
  records may still be expunged when not recently used.
  Implementations that always make root zone contents available
  (e.g. via classic RFC8806 parallel infrastructure or special cache
  markings) will be completely protected.

## Record Protection {#records}

DNSSEC RRSIG records protect all data in the root zone aside from the
glue records associated with each NS record.

### Non-Glue Records

All of the root zone records, aside from the glue records, are
protected by DNSSEC and thus cannot be modified without detection.  As
such, solutions for ensuring tamper-resistant access to the root zone
non-glue records include:

- DNSSEC: Complete

  (assuming validation is performed using a root zone DNSSEC trust
  anchor)
  
- LocalRoot: Complete

  Because the entire root zone is downloaded and checked with both the
  DNSSEC and ZONEMD records, modification of all data is properly
  protected.  Note that if ZONEMD records are not checked, then glue
  records may not be properly protected.
  
- DNS over TLS / DTLS / DoH: Complete

  If the resolver is able to connect to a root server instance that
  offers TLS, DTLS, DoH, or DoQ support and properly verify that
  they've connected to the right root server instance then any answers
  they receive over that protected path can be considered properly
  validated, even without checking the DNSSEC records.  Although
  checking the DNSSEC records for validity themselves is still
  recommended.

### Glue Protection {#glue}

Although DNSSEC protects the NS records within the root zone data, the
A and AAAA glue records are not signed.  Thus they could be modified
by machine-in-the-middle attacks, cache injection techniques, etc to
either block traffic by changing the addresses to servers that don't
respond, or to alternate addresses that do respond.  For addresses
that do respond, they will unable to alter root or TLD related data
without being detected by validating resolvers, however even while
responding with properly signed records they could be used as a form
of surveillance by continuing to proxy legitimate requests while
recording the transactions.  Note that glue records from the root
zone, like NS records, are typically cached for a lengthy period of
time, which is a benefit for resolvers that receive the correct
records but a detriment for those that receive modified records.

Solutions to this problem space include:

- DNSSEC: Moderate

  {{RFC9364}} prevents malicious modification of critical data,
  thus preventing false insertion of data that is not signed.
  However, it does not prevent glue record modification.

- LocalRoot implementations {{LOCALROOT}} download and verify the entire
  contents of the root zone, including glue records, and thus
  eliminates this threat entirely.

- DNS over TLS / DTLS / DoH: Complete

  Like with non-glue records, because the channel is considered secure
  to the root server instance (when its identity is properly
  verified), then the data received over the channel can be considered
  secured.  The glue records cannot, however, be checked after
  reception for DNSSEC validity since no RRSIGs on the glue records
  will be present.

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
