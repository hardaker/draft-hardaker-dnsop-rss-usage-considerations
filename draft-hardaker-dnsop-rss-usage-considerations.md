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
  -
    fullname: Warren Kumari
    organization: Google
    email: warren@kumari.net

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
  RFC9250:
  RFC9364:
  RFC9539:
  KNOTMODULE:
    title: know module to support LocalRoot
    target: https://knot-resolver.readthedocs.io/en/latest/lib.html
  BINDMIRROR:
    title: bind instructions for mirroring the root zone
    target: https://bind9.readthedocs.io/en/v9.18.41/reference.html
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
  QUERYCOMPOSITION:
    title: Understanding DNS Query Composition at B-Root
    target: https://arxiv.org/pdf/2308.07966
  DITL:
    title: A Day In The Life of the Internet
    target: https://www.dns-oarc.net/oarc/data/ditl
  DNSMAGNITUDE:
    title: ICANN DNS Magnitude statistics page
    target: https://magnitude.research.icann.org/
  DNSMAGNITUDE2020:
    title: DNS Magnitude - A Popularity Figure for Domain Names, and its Application to L-root Traffic
    target: https://www.icann.org/en/system/files/files/dns-magnitude-05aug20-en.pdf

--- abstract

This document explores various technologies developed to enhance the DNS,
focusing specifically on interactions with the DNS Root Server System (RSS). It
examines a number of the protocols and evaluates their impact on
communication with the RSS.

--- middle

# Introduction

This document explores various technologies developed to enhance the DNS,
focusing specifically on interactions with the DNS Root Server System (RSS). It
examines a number of the protocols and evaluates their impact on
communication with the RSS.

While the necessity of a centralized source for a unique internet naming system
is beyond the scope of this document, it is thoroughly addressed in
{{RFC2826}}.

The document begins by briefly describing and referencing various communication
enhancements in {{techniques}}. It then provides an analysis of how these
enhancements impact communication with the RSS in {{analysis}}.

## Document Conventions

To evaluate the potential changes to RSS communication in {{analysis}}, this
document categorizes the solutions using the following keywords:

- **Minimal**: The technique addresses a problem with only a minimal amount
  of improvement.
- **Moderate**: The technique provides a moderate level of improvement in
  addressing a problem.
- **Significant**: The technique offers substantial improvement for
  communicating with the RSS, even though it does not entirely address the
  problem space.
- **Complete**: The technique fully enhances communication with the RSS and/or
  completely mitigates the defined concern.

# Techniques Improving Communication with the RSS {#techniques}

This section outlines various techniques designed to improve
communication with the DNS Root Server System (RSS), particularly in
addressing security or efficiency concerns.  These techniques are
further analyzed in {{analysis}} to evaluate their effectiveness in
mitigating each of the concerns.

## QName Minimization

The original DNS protocol specifications {{RFC1035}} indicated that
the entire query name being handled by a resolver should be sent to
upstream authoritative servers; this leaks all labels in a query to
all the authoritative servers used in the resolution process even when
the authoritative server doesn't need all the labels to generate a
response.  The "DNS Query Name Minimisation to Improve Privacy"
{{RFC9156}} specification describes how recursive resolvers can
minimize this privacy leakage by describing how the resolver "no
longer always sends the full original QNAME and original QTYPE to the
upstream name server."

## Aggressive NSEC

The "Aggressive Use of DNSSEC-Validated Cache" {{RFC8198}} {{RFC9077}}
specification describes how validating recursive resolvers can reduce the
number of queries sent to authoritative servers by allowing "DNSSEC-validating
resolvers to generate negative answers within a range and positive answers from
wildcards."

This technique is particularly effective in reducing queries to the RSS for
non-existent TLDs, as once a single query between two valid TLDs has been sent,
validating resolvers can make use of the returned NSEC records to prevent
future queries between the two bounding TLDs from needing resolution. This
improves both privacy and latency when communicating with the RSS, as fewer
queries are sent and more responses can be generated from the cache.


## Encrypted DNS

There are a variety of protocols that enable encrypted DNS
transactions both between stubs and recursive resolvers, and recursive
resolvers and authoritative servers. These include "DNS over Transport
Layer Security" (TLS) {{RFC7858}} and "DNS over Datagram Transport
Layer Security (DTLS)" {{RFC8094}} (along with supplemental
information {{RFC8310}}) which collectively are referred to as "DNS
over (D)TLS".

In addition, "DNS Queries over HTTPS (DoH)" {{RFC8484}}, "DNS over Dedicated QUIC
Connections" {{RFC9250}}, and "Oblivious DNS over HTTPS" {{RFC9230}} enable DNS
over encrypted HTTP transports.

By encrypting the communication, these protocols prevent intermediate entities
from observing the contents of DNS queries, thus improving privacy for users.

The "Unilateral Opportunistic Deployment of Encrypted Recursive-to-Authoritative"
DNS {{RFC9539}} specification defines how recursive resolvers can communicate
with authoritative servers that support encrypted TLS sessions. However,
the specification is currently published under an EXPERIMENTAL status.

## Serve Stale

The "Serving Stale Data to Improve DNS Resiliency" {{RFC8767}} specification
specifies how resolvers can continue to serve previously cached records even
after their Time-To-Live (TTL) has expired. This approach enhances DNS
resiliency by ensuring that responses remain available during periods when
authoritative servers are unreachable, such as during network outages or server
failures.

## DNSSEC

DNSSEC {{RFC9364}} provides cryptographic assurance of the authenticity and
integrity of DNS responses. Using digital signatures, DNSSEC ensures that data
from the root and other signed zones cannot be maliciously modified without
detection. This allows validating resolvers, and their clients, to verify the
origin, authenticity, and correctness of DNS data.

## LocalRoot

LocalRoot enables recursive resolvers to maintain and use a local copy
of the root zone, eliminating the need to query the root servers
directly. This concept has been documented for over a decade in
{{RFC7706}}, {{RFC8806}}, and {{LOCALROOT}}, and in academic research
{{NOROOTS}}, {{ROOTPRIVACY}}. It is implemented in {{BINDMIRROR}},
{{KNOTMODULE}}, {{UNBOUNDAUTHZONE}}, {{LOCALROOTISI}}.

The initial LocalRoot implementations relied on AXFR for transferring
root zone data. More recent implementations instead support HTTP-based
transfers, providing additional flexibility and scalability.

By using LocalRoot, resolvers can improve privacy, reduce dependency
on external servers, and ensure consistent access to root zone data.

# Centralized vs Decentralized RSS Characteristics {#analysis}

This section evaluates the impact of the techniques described in {{techniques}}
on recursive resolvers' communication with the Root Server System (RSS).

## Privacy

Queries sent to the RSS include those within existing Top-Level Domains (TLDs)
(e.g., ".com", ".org") and for queries under non-existent domains (e.g.,
"sensitive.internal", sensitive.con" (sic)).

When a resolver's cache lacks an answer for the associated TLD, the
query is forwarded to the RSS. This exposes the query to the 12 Root
Server Operators (RSOs) managing the 26 RSS identifiers (13 IPv4 and
13 IPv6) and the networks in between.

The privacy sensitivity of queries sent to the RSS can vary widely
ranging from unlikely sensitive (such as a query for just ".example"
without any left-hand labels) to more critical queries that leak
potentially personal or system-sensitive information that was not
intended to leak beyond an internal network boundary (such as
".wpad").  Names reaching the RSS could be single labels that reveal
only the TLD's name (".com" or ".xxx") and may or may not be sensitive
in nature.  Queries could also contain more labels that leak
more sensitive information ("private.sensitive.example").

Accidental leaks can stem from typos, web browser keyword searches,
misconfigured software, or simply because it needed to be resolved,
and no privacy-protecting techniques listed below were deployed.

Note that beyond the analysis of a single record being observed, a
larger or temporal analysis of all of a client's queries may reveal
additional information and/or behavioral patterns ({{ROOTPRIVACY}}).
For example, the collection of unique ccTLDs observed during the
course of a 24 hour period may reveal the political bias in a
resolver's clients.

To mitigate issues with potentially sensitive queries leaving a resolver,
various techniques are available for use that include:

- **Aggressive NSEC: Significant**

  [ Ed note: The NSEC example is as of this writing, and may change over time]
  Aggressive NSEC leverages NSEC records to prevent redundant queries for
  non-existent TLDs. Validating resolvers can use NSEC records to synthesize
  negative responses for non-existent TLDs based on previously received NSEC
  records. For example, a query for a non-existent TLD (e.g.,
  ".example") will return an NSEC record cryptographically proving that the no
  names between ".events" and ".exchange" exist. Subsequent queries within the NSEC
  TTL for a non-existent TLD that falls between ".events" and ".exchange" (e.g.,
  ".evil") can be answered immediately without sending a query to the RSS.

  The rough worst-case scenario with a long lived cache is a transmission of 1
  query per TLD in the root zone in the course of one TTL (2 days, or other
  implementation upper limit which can commonly be 1 day).  Note that resolvers
  that prefer client NS records, which often have a lower TTL, may send data
  more frequently than what the root zone's TTL specifies.  Note that DNSSEC
  (or at least an understanding of the NSEC record) is required to implement
  Aggressive NSEC.

- **QName Minimization: Significant**

  QName Minimisation greatly improves privacy in the case where any
  sensitive information is in the labels before the TLD
  (e.g. sensitive.example).  However, this cannot entirely minimize
  the leakage of TLD names themselves, which may or may not be
  sensitive in nature (".xxx" is used as a common example of a TLD
  that may be considered sensitive).  Note that like the Aggressive
  NSEC technique above, the sent queries are typically cached for a
  period of time.  Unlike NSEC Aggressive Caching though, DNSSEC is
  not required to implement QName Minimization.

- **Encrypted DNS: Moderate**

  Encrypted DNS protocols, such as DNS over TLS, protect queries from
  intermediate observers by encrypting the communication. However, as of this
  writing, only two of the 13 root server identifiers support encrypted DNS,
  limiting the effectiveness of this technique.

- **LocalRoot: Complete**

  LocalRoot implementations maintain a local copy of the root zone,
  thereby completely eliminating the need to send queries to the
  RSS. This ensures complete privacy with respect the RSS, as no
  queries leave the resolver toward the RSS.

  Furthermore, because the data is received and verified before being
  used, there are only two remaining sources of trust for the
  information used: IANA itself and the RZM which is responsible for
  creating the root zone, although even they have no visibility into
  how resolvers make use of the data.

## Latency

Even though almost all answers to user queries are served from the cache, many
resolver operators are concerned about the latency of queries sent to the RSS.
In addition, because negative answers are frequent and may be
from end-user typos or similar, latency to the RSS does matters at
least a little as a user may be directly waiting for a response before
realizing their error.  In fact, this is one motivation listed in
{{RFC8806}} for implementing LocalRoot.

Techniques that support reducing latency to the root, often by having
the answers already available, include:

- **Aggressive NSEC: Significant**

  With Agressive NSEC deployed, queries containing right-most labels
  (TLD labels) that are not in the root and are covered by an NSEC
  record that is in the (validating) resolver's cache are not sent and
  thus answerable immediately.  The result is similar to privacy
  analysis showing that Aggressive NSEC provides significant latency
  reduction to the root zone.

- **LocalRoot: Complete**

  As above, a LocalRoot implementation already has the information in
  the root zone and thus can answer immediately and without sending
  any queries to the RSS.

- **Serve Stale: N/A**

  Note that though Serve Stale may have an answer in the cache that is
  usable, it does not help with latency since the answer should not be
  used until an attempt to query the RSS has already been made.

## Disconnected operations

At times a region may become disconnected from the larger internet
from a variety of causes (network outages, intentional disruptions,
natural catastrophes, etc).  In this situation, because the RSS serves
as the pinnacle of the DNS, any resolver needing information about
TLDs not in their cache would be effectively unable to respond to that
branch of the DNS tree.  Obviously a complete disconnection from the
Intenet means all resolutions will fail, but at times local
infrastructure may still be viable and reachable (for example, a ccTLD
may be reachable even when the RSS is not).

Solutions available for resolvers to continue operating even when
disconnected from the RSS:

- **Serve Stale: Significant**

  As Serve Stale allows resolvers to re-use past data when
  authoritative servers are unreachable, it significantly helps in
  disconnected situations as long as the needed records are in the
  cache.

- **LocalRoot: Significant or Complete**

  LocalRoot implementations that fill their cache with records from
  the root zone should be similarly protected as Serve Stale, as cache
  records may still be expunged when not recently used.
  Implementations that always make root zone contents available
  (e.g. via classic RFC8806 parallel infrastructure or special
  don't-expunge cache flags) will be completely protected from a
  disconnection with the RSS.

## Record Protection {#records}

DNSSEC RRSIG records protects resource records (RRs) in DNS zones.
The only exception to this protection is when data records are
intended to be helpful as they're authoritative in a child.  These
unprotected records on the parent side include both NS records served
by the parent and associated address records (glue records).  Once the
parent has requested the same information from the child, and the DS
record has been followed, then the child's information becomes
authoritative and verified.  However, if the parent side's information
is modified in any way, it may lead the resolver to the wrong
infrastructure at least initially.  With DNSSEC validation happening
this should result in a denial of service or temporary eves-dropping
issue at most.

For analyzing how the techniques listed in this draft affect these
communication patterns, we break the analysis into two parts of the
RSS (parent) record sets: authoritative RR protection and
non-authoratative (glue) records.

### Authoritative RR Protection

All of the root zone records, aside from the NS and glue records, are
protected by DNSSEC and thus cannot be modified without detection.  As
such, solutions for ensuring tamper-resistant access to the root zone
non-glue records include:

- **DNSSEC: Significant**

  DNSSEC protects against record modification for records served from
  the RSS, assuming validation is performed using a root zone DNSSEC
  trust anchor and followed all the way to the child zone.  Note that
  not all records in the root zone are protected, and thus this
  is considered Significant since most TLDs do offer DNSSEC support.

  Note that because DNSSEC combined with NSEC records allows
  verification of negative answers received from the root.  The
  non-existent records are actually authoratative at the root.

- **LocalRoot: Complete**

  Because the entire root zone is downloaded and checked with both the
  DNSSEC and ZONEMD records, modification of all data is properly
  protected.  Note this requires proper DNSSEC validation of at least
  the ZONEMD record.

- **Encrypted DNS: Complete**

  If the resolver is able to connect to a root server instance that
  offers authenticated and encrypted DNS support, then any answers
  they receive over that protected path can be considered properly
  validated, even without checking the corresponding DNSSEC records.
  Although checking the DNSSEC records for validity themselves is
  still recommended.  And this presumes that some trust mechanism is
  used to bootstrap the authentication of the RSS instance used.

### Non-authoratative Data (Glue) Protection {#glue}

Although DNSSEC protects many of the records within the root zone, the
TLD's NS, A and AAAA records are not signed.  Thus they could be
modified by machine-in-the-middle attacks, cache injection techniques,
etc to either block traffic by changing the addresses to servers that
don't respond to create a denial of service issue.

Alternatively, they can be modified to point to alternate addresses
that actually do respond.  These addresses will be unable to alter
records that have been properly verified with DNSSEC, however even
while responding with properly signed records they could be used as a
form of surveillance by continuing to proxy legitimate requests while
recording the transactions.  Note that NS and glue records from the
root zone are typically cached for a lengthy period of time, which is
a benefit for resolvers that receive the correct records but a
detriment for those that receive modified records and have a
parent-side preference.

Solutions to this problem space include:

- **DNSSEC: None to Significant**

  DNSSEC prevents malicious modification of critical data, thus
  preventing false insertion of data that is not signed.  However, it
  does not prevent NS and glue record modification.  The protection
  offered by DNSSEC depends on whether the resolver uses DNSSEC to
  validate the child side NS, A and AAAA records or only believes
  caches and uses the parent records.  Furthermore the TLD in use must
  be signed for this protection to be effective.

- LocalRoot implementations {{LOCALROOT}} download and verify the
  entire contents of the root zone, including NS and glue records, and
  thus eliminates this threat entirely.

- **Encrypted DNS: Complete**

  Like with non-glue records, because the channel is considered secure
  to the root server instance (when its identity is properly
  verified), then the data received over the channel can be considered
  authentic (and encrypted).  The NS and glue records cannot, however,
  be checked after reception for DNSSEC validity since no RRSIGs on
  the glue records will be present and thus the child must be
  consulted as well.

## Bit Flipping

Bit flipping is defined as accidental modifications to bits due to
memory corruption in one of the processing hosts or during
transmission.  The net effect is that at least one bit may flip
randomly from 0 to 1, or vice versa, although hopefully with low
probability.  Though rare, they have been measured in the world in
network traffic arriving at very popular servers of all types.

The root-servers.net zone is, unsurprisingly, a very popular domain:
it bootstaps all Internet DNS resolutions.  Researchers have shown
that by registering alternate domain names with single or double bit
flips in the root-servers.net domain name allows these alternate
servers to receive requests to them intended to be sent to the real
root-servers.net domain.  These bit flips can cause problems similar
to as the above discussed glue record modifications ({{glue}}).

Cyptographic techniques like DNSSEC properly identify and reject data
with modifications of any kind, including bit flipping techniques.
Note that in this section we only discuss bitflips that are received
by the resolver, or for answers coming back to queries from the RSS as
an authoritative server being queried.  Bitflips that occur in packets
leaving the resolver toward the client submitting the original request
are out of scope and not covered in this document as the resolver has
no control over them.

Solutions to detecting and rejecting bitfliped data include:

- **DNSSEC: Significant**

  Prevents malicious modification of critical data, thus preventing
  data bit flips of DNSSEC signed data.  However, it does not prevent
  NS and glue record modification as glue records, as discussed above,
  are not protected by DNSSEC unless verified through to the client's
  copy of the records.

  Research has shown that some validating resolvers fail to detect
  when some bit flipping situations have occurred, however.

- **LocalRoot: Complete**

  LocalRoot implementations download and verify the entire contents of
  the root zone, including glue records, and thus eliminates this
  threat entirely for incoming queries.

# Summary

In summary, the following table summarizes the analysis in
{{analysis}} given the DNS communication technologies in
{{techniques}} and how they affect communication with the RSS.

|---------------|--------|--------|----------|--------|--------|-----------|
|               | QName  | Aggr.  | Encrypt  | Serve  | DNSSEC | LocalRoot |
|               | Min    | NSEC   | DNS      | Stale  |        |           |
|---------------|--------|--------|----------|--------|--------|-----------|
| Privacy       | Signif | Signif | Moderate |        |        | Complete  |
| Latency       |        | Signif |          |        |        | Complete  |
| Disconnection |        |        |          | Signif |        | Complete* |
| Auth Prot     |        |        | Complete |        | Signif | Complete  |
| Non-auth Prot |        |        | Complete |        | Signif | Complete  |
| Bit Flipping  |        |        |          |        | Signif | Complete  |
|---------------|--------|--------|----------|--------|--------|-----------|

(*): as discussed above, this depends on the implementation with some
implementations only being Significant while others are Complete.

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
