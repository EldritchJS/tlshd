FROM registry.access.redhat.com/ubi9/ubi

RUN --mount=type=secret,id=rhel-org-id \
    --mount=type=secret,id=rhel-activation-key \
    if [ -s /run/secrets/rhel-activation-key ]; then \
      subscription-manager register \
        --org="$(cat /run/secrets/rhel-org-id)" \
        --activationkey="$(cat /run/secrets/rhel-activation-key)" && \
      subscription-manager repos \
        --enable rhel-9-for-x86_64-baseos-rpms \
        --enable rhel-9-for-x86_64-appstream-rpms; \
    fi && \
    ( dnf install -y ktls-utils || \
      { echo "=== ktls-utils not found; repos visible were: ==="; \
        subscription-manager repos --list-enabled | grep -E "^Repo ID" || dnf repolist; \
        exit 1; } ) && \
    dnf clean all && \
    if [ -s /run/secrets/rhel-activation-key ]; then \
      subscription-manager unregister; \
    fi

CMD ["/usr/sbin/tlshd", "-s"]
