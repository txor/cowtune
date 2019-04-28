FROM perl:slim
RUN mkdir -p /opt/cowtune
RUN apt update && apt install -y fortune cowsay dos2unix
COPY cowtune.pl /opt/cowtune
CMD perl /opt/cowtune/cowtune.pl
