FROM ubuntu:22.04

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]


# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG C.UTF-8
ENV ODOO_VERSION 16.0
ENV ODOO_RC /etc/odoo/odoo.conf

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        xz-utils \
        adduser \
        fonts-dejavu-core \
        fonts-freefont-ttf \
        fonts-freefont-otf \
        fonts-noto-core \
        fonts-inconsolata \
        fonts-font-awesome \
        fonts-roboto-unhinted \
        gsfonts \
        libjs-underscore \
        lsb-base \
        wkhtmltopdf \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        postgresql-client \
        python3-babel \
        python3-chardet \
        python3-dateutil \
        python3-decorator \
        python3-docutils \
        python3-freezegun \
        python3-pil \
        python3-jinja2 \
        python3-libsass \
        python3-lxml \
        python3-num2words \
        python3-ofxparse \
        python3-passlib \
        python3-polib \
        python3-psutil \
        python3-psycopg2 \
        python3-pydot \
        python3-openssl \
        python3-pypdf2 \
        python3-qrcode \
        python3-renderpm \
        python3-reportlab \
        python3-requests \
        python3-stdnum \
        python3-tz \
        python3-vobject \
        python3-werkzeug \
        python3-xlsxwriter \
        python3-xlrd \
        python3-zeep \
        python3-ldap \
        python3-gevent \
    && pip install \
        openupgradelib \
        jdatetime \
        persiantools \
    && pip cache purge \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/*

# install latest wkhtmltopdf
RUN apt-get update && \
    apt-get install --no-install-recommends -y wkhtmltopdf \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/*
# RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
#     && echo '800eb1c699d07238fee77bf9df1556964f00ffcf wkhtmltox.deb' | sha1sum -c - \
#     && apt-get install --no-install-recommends -y xfonts-base ./wkhtmltox.deb \
#     && rm -rf wkhtmltox.deb \
#     && rm -rf /var/lib/apt/lists/* \
#     && rm -rf /var/logs/*

# install latest postgresql-client
# RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
#     && GNUPGHOME="$(mktemp -d)" \
#     && export GNUPGHOME \
#     && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
#     && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
#     && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
#     && gpgconf --kill all \
#     && rm -rf "$GNUPGHOME" \
#     && apt-get update  \
#     && apt-get install --no-install-recommends -y postgresql-client \
#     && rm -f /etc/apt/sources.list.d/pgdg.list \
#     && rm -rf /var/lib/apt/lists/* \
#     && rm -rf /var/logs/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss \
    &&  npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*

COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN adduser --system \
        --home /var/lib/odoo \
        --quiet --group odoo \
    && chown odoo:odoo /var/lib/odoo \
    && chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
# USER odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
