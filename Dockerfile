# Imagen base oficial de Jupyter con el stack científico (pandas, numpy, scipy,
# matplotlib, seaborn, scikit-learn). La etiqueta se fija para que el entorno
# sea reproducible; se puede cambiar con --build-arg BASE_TAG=<etiqueta>.
ARG BASE_TAG=python-3.12
FROM quay.io/jupyter/scipy-notebook:${BASE_TAG}

# Dependencias adicionales (si las hay) declaradas en requirements.txt.
# Se copian con el dueño correcto para el usuario no-root de la imagen (jovyan).
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Directorio de trabajo dentro del contenedor (montado desde ./work).
WORKDIR /home/${NB_USER}/work
