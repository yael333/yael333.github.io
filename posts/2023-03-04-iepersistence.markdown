---
title: "Achieving Malware Persistence through Microsoft Internet Explorer - Introductory"
---


One of the most undeniable and topics concern with Microsoft\'s smash hit Windows is the bloat in software and features. It is a focal point point in malware targeting, abusing poorly designed systems and preying on it\'s huge userbase.

All of it undeniably ties in into The Browser Wars Microsoft found themselves in, all tech corps trying to shill their spyware packaged with an open-source web browser engine. Besides my serious non important opinions on the matter, I think we\'re all familiar with Internet Explorer, an old piece of tech that still comes packaged on all Windows systems and is damn near impossible to get rid off.

Per usual, let\'s try to abuse the fact it is so atomic to Window\'s user experience and try to achieve some sort of malware persistence.
I opened procmon from the sysinternals utilities suite looking for potential DLL injections, in the case IE tries to load non existent / or creates it\'s own DLLs we\'re able to intervene and load our \"malicious\" ones. \
Using these filters, we can look for specific kinds of DLLs that only exist on runtime:

![](../img/iepersistence/filters.png)