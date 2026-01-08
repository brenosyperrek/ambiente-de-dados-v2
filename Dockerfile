#Dockefile
FROM apache/airflow:3.0.0-python3.12

USER root

# Copia o Instant Client
COPY oracle_client/instantclient_21_13/instantclient_21_13 /opt/oracle/instantclient_21_13

# Fix apt repository URLs
RUN sed -i 's|http://deb.debian.org|https://deb.debian.org|g' /etc/apt/sources.list.d/debian.sources \
    && sed -i 's|http://snapshot.debian.org|https://snapshot.debian.org|g' /etc/apt/sources.list.d/debian.sources

# Instala dependências do Instant Client
RUN apt-get update && \
    apt-get install -y libaio1 libaio-dev libnsl2 unzip && \
    rm -rf /var/lib/apt/lists/*

# Registra o Instant Client no sistema
RUN echo /opt/oracle/instantclient_21_13 > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# Variáveis de ambiente do Oracle
ENV LD_LIBRARY_PATH="/opt/oracle/instantclient_21_13:${LD_LIBRARY_PATH}"
ENV PATH="${PATH}:/opt/oracle/instantclient_21_13"
ENV ORACLE_HOME="/opt/oracle/instantclient_21_13"

USER airflow

# Recomendado: instalar dependências usando constraints do Airflow
# (evita o pip tentar "mexer" na versão do airflow ou quebrar providers)
COPY requirements.txt /requirements.txt
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /requirements.txt --constraint /home/airflow/constraints.txt
