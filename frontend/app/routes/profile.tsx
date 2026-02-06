import type {Route} from "./+types/home";
import {ProfileForm} from "~/components/profileForm";
import ProtectedRoute from "~/components/protectedRoute";


export function meta({}: Route.MetaArgs) {
    return [
        {title: "hprod - Profile"},
        {name: "description", content: "Welcome to React Router!"},
    ];
}

export default function Profile() {
    return <ProtectedRoute>
        <ProfileForm/>
    </ProtectedRoute>;
}
