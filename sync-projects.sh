#!/bin/bash

USERNAME="chaithanya1747"

sync_project() {
    REPO="$1"

    echo ""
    echo "========== Checking $REPO =========="

    if [ ! -d "$REPO" ]; then
        echo "FOLDER NOT FOUND: $REPO"
        return
    fi

    if ! gh repo view "$USERNAME/$REPO" >/dev/null 2>&1; then
        echo "GITHUB REPOSITORY NOT FOUND: $REPO"
        return
    fi

    cd "$REPO" || return

    if [ ! -d ".git" ]; then
        git init -b main || { cd ..; return; }
    fi

    git branch -M main

    if git remote get-url origin >/dev/null 2>&1; then
        git remote set-url origin "https://github.com/$USERNAME/$REPO.git"
    else
        git remote add origin "https://github.com/$USERNAME/$REPO.git"
    fi

    git add -A || { cd ..; return; }

    if ! git diff --cached --quiet; then
        git commit -m "Sync project files" || { cd ..; return; }
    fi

    git fetch origin || { echo "FETCH FAILED"; cd ..; return; }

    if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
        if ! git merge-base HEAD origin/main >/dev/null 2>&1; then
            echo "Unrelated histories: manual review required"
            cd ..
            return
        fi

        if ! git merge --no-edit origin/main; then
            echo "MERGE CONFLICT: $REPO"
            cd ..
            return
        fi

        if git diff --quiet HEAD origin/main; then
            echo "ALREADY SYNCHRONIZED: $REPO"
            cd ..
            return
        fi
    fi

    if git push -u origin main; then
        echo "SUCCESS: $REPO"
    else
        echo "PUSH FAILED: $REPO"
    fi

    cd ..
}

sync_project "ecr-docker-node-app-main"
sync_project "express-middleware-app-main"
sync_project "faculty-file-persist-app"
sync_project "mern-crud-app-main"
sync_project "mongodb-express-app-main"
sync_project "mongodb-mongoose-movies-app-main"
sync_project "mongoose-express-app-main"
sync_project "mvc-auth-app-main"
sync_project "mvc-express-app-main"
sync_project "products-file-persistence-app-main"
sync_project "react-conditional-rendering-app-main"
sync_project "react-form-events-app-main"
sync_project "react-frontend-crud-app-main"
sync_project "react-html-render-app-main"
sync_project "react-jsx-render-app-main"
sync_project "react-nested-components-app-main"
sync_project "react-rendering-lists-app-main"
sync_project "react-router-app-main"
sync_project "react-state-events-app-main"
sync_project "template-engine-ejs-app-main"

echo ""
echo "ALL PROJECTS CHECKED"
