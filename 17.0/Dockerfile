FROM ubuntu:jammy

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Retrieve the target architecture to install the correct wkhtmltopdf package
# ARG TARGETARCH amd64

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        git \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-wheel \
        python3-venv \
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
        xz-utils \
    && TARGETARCH=amd64 \
    && WKHTMLTOPDF_ARCH=amd64 \
    && WKHTMLTOPDF_SHA=967390a759707337b46d1c02452e2bb6b2dc6d59  \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_${WKHTMLTOPDF_ARCH}.deb \
    && echo ${WKHTMLTOPDF_SHA} wkhtmltox.deb | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/* \
    && rm -fr /tmp/* 

# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/* \
    && rm -fr /tmp/* 

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/* \
    && rm -fr /tmp/* 

# Install Odoo tools
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        adduser \
        fonts-dejavu-core \
        fonts-freefont-ttf \
        fonts-freefont-otf \
        fonts-noto-core \
        python3-cachetools \
        fonts-inconsolata \
        fonts-font-awesome \
        fonts-roboto-unhinted \
        gsfonts \
        libjs-underscore \
        lsb-base \
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
        python3-odf \
        python3-pydot \
        python3-openssl \
        python3-pypdf2 \
        python3-qrcode \
        python3-renderpm \
        python3-reportlab \
        python3-requests \
        python3-stdnum \
        python3-vobject \
        python3-werkzeug \
        python3-xlsxwriter \
        python3-xlrd \
        python3-zeep \
        python3-ldap \
        python3-gevent \
        python3-rjsmin \
        python3-geoip2 \
        python3-idna \
        python3-markupsafe \
        python3-geojson \
        python3-shapely \
        python3-validators \
        python3-cachetools \
    && pip install \
        openupgradelib \
        jdatetime \
        persiantools \
        pytz==2023.3 \
    && pip cache purge \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/logs/* \
    && rm -fr /tmp/* 

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh     /
COPY ./tools/odoo-update /usr/bin/
COPY ./tools/odoonix-backup /usr/bin/
COPY ./tools/odoonix-drop /usr/bin/
COPY ./tools/odoonix-duplicate /usr/bin/
COPY ./tools/odoonix-load /usr/bin/
COPY ./tools/odoonix-rename /usr/bin/
COPY ./odoo.conf         /etc/odoo/
COPY ./wait-for-psql.py  /usr/local/bin/wait-for-psql.py

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN adduser --system \
        --home /var/lib/odoo \
        --quiet --group odoo \
    && chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons \
    && chmod +x /usr/bin/odoo-update \
    && chmod +x /usr/bin/odoonix-backup \
    && chmod +x /usr/bin/odoonix-drop \
    && chmod +x /usr/bin/odoonix-duplicate \
    && chmod +x /usr/bin/odoonix-load \
    && chmod +x /usr/bin/odoonix-rename 
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf


# Set default user when running the container
#USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]






