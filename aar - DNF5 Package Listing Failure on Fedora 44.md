AFTER-ACTION REPORT: DNF5 Package Listing Failure on Fedora 44
Date: June 07, 2026
System: Tuofudun L10 Laptop (Alder Lake-N Platform)
OS: Fedora 44 kde (DNF5)
Subject: Resolution of dnf list installed returning no results despite functional RPM database

1. Executive Summary
During routine system inventory operations, the command dnf list installed consistently returned "No matching packages to list" despite confirmed package presence via rpm -qa. Root cause was identified as DNF5 syntax incompatibility — the list installed subcommand does not function identically in DNF5 as it did in DNF4. The working equivalent is dnf repoquery --installed. No data loss, corruption, or system damage occurred; the issue was entirely a command-interface change between major DNF versions.

2. Incident Timeline
Time	Event
~22:43	User executes dnf list installed — returns "No matching packages to list"
~22:43	awk piped version also fails — same empty result
~22:44	Attempted rpm -qa --last | head -50 — returns 50 packages successfully
~22:45	Executed sudo dnf clean all + cache rebuild — no change
~22:46	Removed /var/lib/dnf/history* — no change
~22:50	Attempted sudo dnf -vv list installed — returns Unknown argument "-v" for command "dnf5"
~22:51	Root cause identified: System is running DNF5, not DNF4
~22:52	Executed dnf repoquery --installed — returns full package list
3. Root Cause Analysis
3.1 Primary Cause: DNF5 Breaking Change
Fedora 44 ships with DNF5 (libdnf5 backend) replacing the legacy DNF4 (libdnf/hawkey backend). DNF5 is a ground-up rewrite with significant command-line interface differences:

Command	DNF4 Behavior	DNF5 Behavior
dnf list installed	Lists all installed packages	Returns empty / "No matching packages"
dnf repoquery --installed	Lists all installed packages	Works correctly
dnf -v / dnf -vv	Enables verbose output	Unknown argument "-v"
The list installed subcommand in DNF5 appears to query a different internal data source than repoquery --installed, potentially its own SQLite transaction cache rather than the live RPM database. When that cache is empty or uninitialized, the command silently returns nothing rather than falling back to the RPM database.

3.2 Contributing Factor: Silent Failure Mode
DNF5 does not emit a warning, error, or deprecation notice when list installed returns zero results. This makes the failure indistinguishable from a genuinely empty system, leading to unnecessary troubleshooting steps (cache clearing, history deletion, SELinux checks).

3.3 Misdiagnosis Path
Initial investigation assumed RPM database corruption based on the empty DNF output. The following steps were taken before identifying the true cause:

✅ rpm -qa — confirmed RPM database healthy
❌ sudo dnf clean all — irrelevant; cache was not the issue
❌ rm -rf /var/lib/dnf/history* — irrelevant; transaction history unrelated
❌ SELinux investigation — unnecessary
✅ sudo dnf -vv list installed — accidentally revealed DNF5 identity via error message
4. Remediation
Immediate Fix
Use the DNF5-compatible command:

# Correct DNF5 syntax for listing installed packages
dnf repoquery --installed

# With formatting
dnf repoquery --installed --qf "%{name}-%{version}-%{release}.%{arch}"

# Quick count
dnf repoquery --installed | wc -l
Alias for Backward Compatibility
Add to ~/.bashrc or ~/.zshrc:

alias dnf-list='dnf repoquery --installed'
Then: source ~/.bashrc

Verification
# Confirm DNF version
dnf --version

# Confirm working output
dnf repoquery --installed | head -5
5. Lessons Learned
Check tool version before troubleshooting. Running dnf --version at the first sign of trouble would have revealed DNF5 immediately and saved ~10 minutes of misdirected effort.

Silent failures are dangerous. DNF5's list installed returning empty output without any warning or error message is a poor UX decision that mimics data loss. A deprecation notice or fallback to repoquery would prevent this confusion.

Trust the source. When rpm -qa works but dnf list installed doesn't, the problem is in the abstraction layer (DNF), not the underlying data (RPM DB).

DNF5 is not a drop-in replacement. Despite sharing the dnf command name, DNF5 has breaking changes in syntax, flags, and behavior. Documentation and habits from DNF4 cannot be blindly transferred.

6. Recommendations
Action	Priority	Owner
Add dnf --version to standard diagnostic playbook	High	User
Create shell aliases for common DNF4 → DNF5 command migrations	Medium	User
Monitor Fedora upstream for DNF5 list installed bug fix or deprecation warning	Low	User
Update personal scripts/documentation referencing dnf list installed	Medium	User
7. Appendix: DNF4 → DNF5 Command Migration Cheat Sheet
DNF4 Command	DNF5 Equivalent
dnf list installed	dnf repoquery --installed
dnf list available	dnf repoquery --available
dnf -v <command>	dnf <command> --verbose
dnf history	dnf history list
dnf info <pkg>	dnf repoquery --info <pkg>
dnf search <term>	dnf search <term> (unchanged)
dnf install <pkg>	dnf install <pkg> (unchanged)
dnf remove <pkg>	dnf remove <pkg> (unchanged)
Report Prepared By: mul-sec
Classification: Internal Technical Record
Status: Closed
